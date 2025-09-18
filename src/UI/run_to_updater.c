/*
* run_to_updater.c
*
* (C) Copyright 2025 AtlantisOS Project
* by @NachtsternBuild
*
* License: GNU GENERAL PUBLIC LICENSE Version 3
*
* callbacks from the main UI are received and passed on to the background scripts 
* 
* Usage:
* run_to_updater("--check");
*
* Notes:
* This works only in the ecosystem of atlantis os
* To test the UI use the test.sh instead of updater.sh 
*/

#include <glib.h>
#include <gtk/gtk.h>
#include <adwaita.h>
#include "design.h"
#include "updater.h"

// define a timer for the pulsing progressbar
guint pulse_timer_id = 0;

// pulsating progress bar
gboolean pulse_progress(gpointer user_data) 
{
    gtk_progress_bar_pulse(GTK_PROGRESS_BAR(progress_bar));
    return TRUE; // TRUE = continue executing
}

// callback for the reading the pipe
gboolean on_output(GIOChannel *source, GIOCondition cond, gpointer data) 
{
    gchar *line = NULL;
    gsize len = 0;

    if (cond & (G_IO_HUP | G_IO_ERR)) 
    {
        return FALSE; // stop watching
    }

    if (g_io_channel_read_line(source, &line, &len, NULL, NULL) == G_IO_STATUS_NORMAL) 
    {
        gtk_label_set_text(GTK_LABEL(status_label), line);
        g_free(line);
    }

    return TRUE; // continue watching
}

// callback when the child process has finished 
// child process is the programm that started by the updater
void on_child_exit(GPid pid, gint status, gpointer data) 
{
    // reset the pulse timer
    if (pulse_timer_id != 0) 
    {
    	g_source_remove(pulse_timer_id);
    	pulse_timer_id = 0;
	}
    
    // end the progress bar
    gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(progress_bar), 1.0);
	gtk_progress_bar_set_text(GTK_PROGRESS_BAR(progress_bar), _("Abgeschlossen"));

    g_spawn_close_pid(pid);
}

// started from the main UI with special callback
void run_to_updater(const char *flag) 
{
    // for testing: use this
    // gchar *argv[] = { "/bin/bash", "test.sh", (gchar *)flag, NULL };
    // updater.sh = main updater scripts
    gchar *argv[] = { "/bin/bash", "updater.sh", (gchar *)flag, NULL };
    GPid pid;
    gint stdout_fd;
    GError *error = NULL;
	
	// create a new background process
    if (!g_spawn_async_with_pipes(NULL, argv, NULL, G_SPAWN_DO_NOT_REAP_CHILD, NULL, NULL, &pid, NULL, &stdout_fd, NULL, &error)) 
    {
        g_printerr("Error with starting: %s\n", error->message);
        g_error_free(error);
        return;
    }

    // watch for the output
    GIOChannel *channel = g_io_channel_unix_new(stdout_fd);
    g_io_add_watch(channel, G_IO_IN | G_IO_HUP, on_output, NULL);
    g_io_channel_unref(channel);
    
    // watch for finished child process
    g_child_watch_add(pid, on_child_exit, NULL);
    
    // run pulsating timer
	pulse_timer_id = g_timeout_add(100, pulse_progress, NULL);
}
