#include <QPushButton>
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QFileDialog>
#include <algorithm>
#include <random>

QString chop_sound_name(std::string s){
    std::string rst;
    for(int i = s.size() - 1; i >= 0; -- i){
        if(s[i] == '.')
            rst.clear();
        else if (s[i] == '/')
            break;
        else rst.push_back(s[i]);
    }
    std::reverse(rst.begin(),rst.end());
    QString qs(rst.c_str());
    return qs;
}

void RecursiveGetMusic(const QString &root, const QStringList &filter, QStringList &rst, QStringList &names){
    QDir *dir = new QDir(root);
    QList<QFileInfo> *dirInfoList = new QList<QFileInfo>(dir->entryInfoList(QDir::Dirs));

    for(int i = 0; i < dirInfoList->count(); ++ i){
        if(dirInfoList->at(i).fileName() == "." || dirInfoList->at(i).fileName() == "..")
            continue;
        QString dirTmp = dirInfoList->at(i).filePath();
        RecursiveGetMusic(dirTmp, filter, rst, names);
    }

    dir->setNameFilters(filter);
    QList<QFileInfo> *fileInfoList= new QList<QFileInfo>(dir->entryInfoList(QDir::Files));
    for(int i = 0; i < fileInfoList->count(); ++ i){
        rst << fileInfoList->at(i).absoluteFilePath();
    }

    delete dir;
    delete dirInfoList;
    delete fileInfoList;
    return;
}

ma_result MainWindow::initialize_engine() {
    ma_result result;
    result = ma_engine_init(NULL, &this->engine);
    return result;
}

void MainWindow::update_new_sound() {
    ma_sound_init_from_file(&engine, playlist[curr_idx].c_str(), 0, NULL, NULL, &sound);
    ma_sound_get_length_in_pcm_frames(&sound,&length);
    ma_sound_get_length_in_seconds(&sound,&length_sec);
    curr_sec = 0.f;
    ui->textBrowser->setText(names.at(curr_idx));
    ui->textBrowser->setAlignment(Qt::AlignCenter);
}

void MainWindow::destroy_engine() {
    ma_engine_uninit(&this->engine);
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    timer = new QTimer(this);

    connect(ui->Load, &QPushButton::clicked, [=](){
        QString dirpath = QFileDialog::getExistingDirectory(this,"pick a directory","./",QFileDialog::ShowDirsOnly);
        if(dirpath == curr_path) return;
        curr_path = dirpath;
        if(playing == true){
            ma_sound_stop(&sound);
            playing = false;
        }
        destroy_engine();
        initialize_engine();
        mp3List.clear();

        QString filterPosefix = "*.mp3";
        QStringList filter;
        filter << filterPosefix;
        RecursiveGetMusic(dirpath, filter, mp3List, names);
        curr_idx = 0;
        total_number = mp3List.size();
        playlist.resize(total_number);
        for(int i = 0; i < total_number; ++ i){
            playlist[i] = mp3List.at(i).toStdString();
        }
        std::random_device rd;
        std::mt19937 rdg(rd());
        std::shuffle(playlist.begin(),playlist.end(),rdg);
        for(int i=0;i<total_number;++i){
            names << chop_sound_name(playlist[i]);
        }

        update_new_sound();

        ma_sound_start(&sound);
        playing = true;
    });

    connect(ui->Stop, &QPushButton::clicked, [=]() {
        if(total_number == 0) return;
        if(playing == true) {
            ma_sound_stop(&sound);
            playing = false;
        } else{
            ma_sound_start(&sound);
            playing = true;
        }
    });
    connect(ui->Left, &QPushButton::clicked, [=]() {
        if(total_number == 0) return;
        if(playing == true){
            ma_sound_stop(&sound);
            playing = false;
        }
        destroy_engine();
        initialize_engine();
        curr_idx = (curr_idx - 1 + total_number) % total_number;
        update_new_sound();

        ma_sound_start(&sound);
        playing = true;
    });
    connect(ui->Right, &QPushButton::clicked, [=]() {
        if(total_number == 0) return;
        if(playing == true){
            ma_sound_stop(&sound);
            playing = false;
        }
        destroy_engine();
        initialize_engine();
        curr_idx = (curr_idx + 1) % total_number;
        update_new_sound();

        ma_sound_start(&sound);
        playing = true;
    });
    connect(ui->horizontalSlider,&QSlider::sliderReleased,[=](){
        if(total_number == 0) {
            ui->horizontalSlider->setValue(0);
            return;
        }
        float volume = ma_sound_get_volume(&sound);
        int value = ui->horizontalSlider->value();
        curr_sec = length_sec * value / 100.f;

        ma_sound_set_volume(&sound,0);
        ma_sound_stop(&sound);
        ma_uint64 time = ma_sound_get_time_in_pcm_frames(&sound);

        ma_sound_seek_to_pcm_frame(&sound,ma_uint64(1.0 * length * value / 100.0));

        ma_sound_set_volume(&sound,volume);
        ma_sound_start(&sound);
    });
    connect(timer,SIGNAL(timeout()), this, SLOT(updateSlider()));
    timer->start(1000);
}

void MainWindow::updateSlider() {
    if(playing == false) return;
    if(curr_sec >= length_sec){
        if(playing == true){
            ma_sound_stop(&sound);
            playing = false;
        }
        destroy_engine();
        initialize_engine();
        curr_idx = (curr_idx + 1) % total_number;
        update_new_sound();

        ma_sound_start(&sound);
        playing = true;
    }
    curr_sec += 1.0f;
    ui->horizontalSlider->setValue(std::min(100.f,curr_sec/length_sec * 100));
}

MainWindow::~MainWindow()
{
    delete ui;
    delete timer;
}
