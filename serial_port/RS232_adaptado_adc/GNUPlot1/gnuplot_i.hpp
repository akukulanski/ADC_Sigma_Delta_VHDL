////////////////////////////////////////////
//
// A C++ interface to gnuplot. 
//
// This is a direct translation from the C interface
// written by N. Devillard (which is available from
// http://ndevilla.free.fr/gnuplot/).
//
// As in the C interface this uses pipes and so wont
// run on a system that doesn't have POSIX pipe 
// support
//
// Rajarshi Guha
// <rajarshi@presidency.com>
//
// 07/03/03
//
////////////////////////////////////////////
//
// A little correction for Win32 compatibility
// and MS VC 6.0 done by V.Chyzhdzenka 
//
// Notes:
// 1. Added private method Gnuplot::init().
// 2. Temporary file is created in th current
//    folder but not in /tmp.
// 3. Added #indef WIN32 e.t.c. where is needed.
// 4. Added private member m_sGNUPlotFileName is
//    a name of executed GNUPlot file.
//
// Viktor Chyzhdzenka
// e-mail: chyzhdzenka@mail.ru
//
// 20/05/03
//
////////////////////////////////////////////

#ifndef _GNUPLOT_PIPES_H_
#define _GNUPLOT_PIPES_H_

#include <stdarg.h>
#ifndef WIN32
#include <unistd.h>
#else
#pragma warning (disable : 4786) // Disable 4786 warning for MS VC 6.0
#endif

#include <cstdlib>
#include <cstdio>
#include <cstring>

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <list>
#include <vector>
#include <stdexcept>

#ifdef WIN32
#define GP_MAX_TMP_FILES    27 //27 temporary files it's Microsoft restriction
#else
#define GP_MAX_TMP_FILES    64
#define GP_TMP_NAME_SIZE    512
#define GP_TITLE_SIZE       80
#endif
#define GP_CMD_SIZE         1024

using namespace std;

class GnuplotException : public runtime_error
{
    public:
        GnuplotException(const string &msg) : runtime_error(msg){}
};

class Gnuplot
{
    private:
        FILE            *gnucmd;
        string           pstyle;
        vector<string>   to_delete;
        int              nplots;
        bool             get_program_path(const string);
        bool             valid;
        //Name of executed GNUPlot file
        string           m_sGNUPlotFileName;
        void init();
    public:
        Gnuplot();

        // set a style during construction
        Gnuplot(const string &);
        
        // The equivalent of gnuplot_plot_once, the two forms
        // allow you to plot either (x,y) pairs or just a single
        // vector at one go
        Gnuplot(const string &, // title
                const string &, // style
                const string &, // xlabel
                const string &, // ylabel
                vector<double>, vector<double>);
        
        Gnuplot(const string &, //title
                const string &, //style
                const string &, //xlabel
                const string &, //ylabel
                vector<double>);
        
        ~Gnuplot();

        // send a command to gnuplot
        void cmd(const string &, ...);

        // set line style
        void set_style(const string &);

        // set y and x axis labels
        void set_ylabel(const string &);
        void set_xlabel(const string &);

        // plot a single vector
        void plot_x(vector<double>, 
                const string & // title
                );

        // plot x,y pairs
        void plot_xy(vector<double>, vector<double>, 
                const string  & // title
                );

        // plot an equation of the form: y = ax + b
        // You supply a and b
        void plot_slope(
                double, // a
                double, // b 
                const string & // title
                );

        // plot an equation supplied as a string
        void plot_equation(
                const string &, // equation 
                const string &  // title
                );

        // if multiple plots are present it will clear the plot area
        void reset_plot(void);

        bool is_valid(void);
        
};

#endif
