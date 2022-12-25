#include "mainwindow.h"
#include <QtWidgets/QApplication>
#include "Style.h"

#include <qfile.h>
#include <qtextstream.h>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // load style sheet
    QString styleFile = QString(CURRENT_DIR)+QString("/Resources/style.qss");
    QFile f(styleFile);
    if (f.exists()){
        f.open(QFile::ReadOnly | QFile::Text);
        QTextStream ts(&f);
        qApp->setStyleSheet(ts.readAll());
    }
    else
        printf("Unable to set stylesheet, file not found\n");

    MainWindow w;
    w.show();
    return a.exec();
}
