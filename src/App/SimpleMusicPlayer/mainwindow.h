#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QString>
#include <QTimer>
//#include <QMediaPlayer>
#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    QStringList mp3List;
    QStringList names;
    int curr_idx;
    int total_number = 0;

    ma_engine engine;
    ma_sound sound;
    bool playing = false;
    QString curr_path = "";

    ma_uint64 length;
    float length_sec;
    float curr_sec;

    ma_result initialize_engine();
    void destroy_engine();
    void update_new_sound();

    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
    QTimer *timer;
private slots:
    void updateSlider();
};

#endif // MAINWINDOW_H
