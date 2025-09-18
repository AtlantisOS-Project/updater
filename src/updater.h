/*
* updater.h
*
* (C) Copyright 2025 AtlantisOS Project
* by @NachtsternBuild
*
* License: GNU GENERAL PUBLIC LICENSE Version 3
*
* Usage:
* #include "updater.h"
*/

#ifndef UPDATER_H
#define UPDATER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>
#include <unistd.h>  
#include <sys/stat.h> 
#include <sys/types.h> 
#include <libintl.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <locale.h>
#include "helper.h"
#include "language.h"
#include "design.h"

// define widget size
#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600

// global widget for the UI
extern GtkWidget *status_label;
extern GtkWidget *progress_bar;
extern GtkWidget *check_button;
extern GtkWidget *download_button;
extern GtkWidget *install_button;
extern GtkWidget *full_button;

// info labels for the updater user info
extern GtkWidget *update_type_label;
extern GtkWidget *version_label;
extern GtkWidget *codename_label;
extern GtkWidget *channel_label;
extern GtkWidget *description_label;

// function that run a special flag to the updater.sh
void run_to_updater(const char *flag);

// create widgets for the update info
void create_update_info_widgets(GtkWidget *parent_box);

// get the update infos from the config file
void update_labels_from_config(void);

// start the main UI of the updater
void activate_updater(GtkApplication *app, gpointer user_data);



#endif // UPDATER_H
