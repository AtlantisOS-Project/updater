/*
* updater.c
*
* (C) Copyright 2025 AtlantisOS Project
* by @NachtsternBuild
*
* License: GNU GENERAL PUBLIC LICENSE Version 3
*
* Notes:
* This works only in the ecosystem of atlantis os
* To test the UI use the test.sh instead of updater.sh 
* This is started by the updater.c (int main)
*/

#include <glib.h>
#include <gtk/gtk.h>
#include <adwaita.h>
#include "design.h"
#include "updater.h"

// widgets for frame and box
GtkWidget *info_update_frame;
GtkWidget *info_update_box;

// info labels
GtkWidget *update_type_label;
GtkWidget *version_label;
GtkWidget *codename_label;
GtkWidget *channel_label;
GtkWidget *description_label;

// define the update state
typedef enum {
    UPDATE_STATE_RUNNING,
    UPDATE_STATE_CHECKED,
    UPDATE_STATE_FINISHED,
    UPDATE_STATE_NOUPDATE,
    UPDATE_STATE_ERROR
} UpdateState;

// define the default status
static UpdateState update_check = UPDATE_STATE_RUNNING;

// create widgets for the update info
void create_update_info_widgets(GtkWidget *parent_box)
{
    // create a new frame
    info_update_frame = gtk_frame_new(_("Update Information"));
    gtk_widget_set_visible(info_update_frame, FALSE); // disable the frame by default

    // create a new box in the frame
    info_update_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4);
    // set the box as child of the frame
    gtk_frame_set_child(GTK_FRAME(info_update_frame), info_update_box);

    // create empty labels
    update_type_label = gtk_label_new("");
    version_label = gtk_label_new("");
    codename_label = gtk_label_new("");
    channel_label = gtk_label_new("");
    description_label = gtk_label_new("");

    // add the labels to the box
    gtk_box_append(GTK_BOX(info_update_box), update_type_label);
    gtk_box_append(GTK_BOX(info_update_box), version_label);
    gtk_box_append(GTK_BOX(info_update_box), codename_label);
    gtk_box_append(GTK_BOX(info_update_box), channel_label);
    gtk_box_append(GTK_BOX(info_update_box), description_label);

    // add the frame to the parent box
    gtk_box_append(GTK_BOX(parent_box), info_frame);
}

// get the update infos from the config file
void update_labels_from_config(void) 
{
    char *update_type = NULL;
    char *version = NULL;
    char *codename = NULL;
    char *channel = NULL;
    char *description = NULL;
	
	// the config file
	// maybe this file are at /tmp
    const char *config_file[] = {
        "./update-remote.conf",
        "/atlantis/updater/update-remote.conf"
    };

    gboolean file_found = FALSE;
	// check for the condif file
    for (int i = 0; i < 2; ++i) 
    {
        if (g_file_test(config_file[i], G_FILE_TEST_EXISTS)) 
        {
            // config file founded
            LOG_INFO("Found update config at: %s", config_file[i]);
            
            // get the infos from the values
            update_type = get_config_value(config_file[i], "UPDATE_TYPE");
            version = get_config_value(config_file[i], "REMOTE_VERSION");
            codename = get_config_value(config_file[i], "REMOTE_CODENAME");
            channel = get_config_value(config_file[i], "REMOTE_CHANNEL");
            description = get_config_value(config_file[i], "REMOTE_DESCRIPTION");
			
			// update update state
            file_found = TRUE;
            update_check = UPDATE_STATE_FINISHED;
            break;
        }
    }
	
	// no config file
    if (!file_found) 
    {
        // system is uptodate
        LOG_INFO("No update config file found → system is up to date.");
        gtk_label_set_text(GTK_LABEL(status_label), _("The system is up to date."));
        update_check = UPDATE_STATE_NOUPDATE;

        // hide the frame
        gtk_widget_set_visible(info_update_frame, FALSE);
        return;
    }

    // buffer for output
    char buffer_io[512];
	
	// update type
    if (!update_type) 
    {
        LOGW("Missing UPDATE_TYPE in config.");
        update_type = g_strdup("N/A");
    }
    snprintf(buffer_io, sizeof(buffer_io), _("Update Type: %s"), update_type);
    gtk_label_set_text(GTK_LABEL(update_type_label), buffer_io);
	
	// version
    if (!version) 
    {
        LOGW("Missing REMOTE_VERSION in config.");
        version = g_strdup("N/A");
    }
    snprintf(buffer_io, sizeof(buffer_io), _("Version: %s"), version);
    gtk_label_set_text(GTK_LABEL(version_label), buffer_io);
	
	// codename
    if (!codename) 
    {
        LOGW("Missing REMOTE_CODENAME in config.");
        codename = g_strdup("N/A");
    }
    snprintf(buffer_io, sizeof(buffer_io), _("Codename: %s"), codename);
    gtk_label_set_text(GTK_LABEL(codename_label), buffer_io);

	// channel
    if (!channel) 
    {
        LOGW("Missing REMOTE_CHANNEL in config.");
        channel = g_strdup("N/A");
    }
    snprintf(buffer_io, sizeof(buffer_io), _("Channel: %s"), channel);
    gtk_label_set_text(GTK_LABEL(channel_label), buffer_io);
	
	// description
    if (!description) 
    {
        LOGW("Missing REMOTE_DESCRIPTION in config.");
        description = g_strdup("N/A");
    }
    snprintf(buffer_io, sizeof(buffer_io), _("Notes: %s"), description);
    gtk_label_set_text(GTK_LABEL(description_label), buffer_io);

    // show the frame
    gtk_widget_set_visible(info_frame, TRUE);

    // free memory
    g_free(update_type);
    g_free(version);
    g_free(codename);
    g_free(channel);
    g_free(description);
}
