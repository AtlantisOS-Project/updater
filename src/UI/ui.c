/*
* ui.c
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

// global widgets
GtkWidget *status_label;
GtkWidget *progress_bar;
GtkWidget *check_button;
GtkWidget *download_button;
GtkWidget *install_button;
GtkWidget *full_button;


// callback for the button
static void on_check_clicked(GtkButton *button, gpointer user_data) 
{
    run_to_updater("--check");
    update_labels_from_config();
}
static void on_download_clicked(GtkButton *button, gpointer user_data) 
{
    run_to_updater("--download");
}
static void on_install_clicked(GtkButton *button, gpointer user_data) 
{
    run_to_updater("--install");
}
static void on_full_clicked(GtkButton *button, gpointer user_data) 
{
    run_to_updater("--full");
}


// main window
void activate_updater(GtkApplication *app, gpointer user_data) 
{
    // start logging
    // using journald - 1
    set_logging_mode(1);

    // use speciell adw theme provider
    use_adw_provider();

    // create the new window
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), _("Updater"));
    gtk_window_set_default_size(GTK_WINDOW(window), WINDOW_WIDTH, WINDOW_HEIGHT);

    // create a new main box
    GtkWidget *content_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
    gtk_window_set_child(GTK_WINDOW(window), content_box);
    gtk_widget_set_halign(content_box, GTK_ALIGN_CENTER);
    gtk_widget_set_valign(content_box, GTK_ALIGN_CENTER);
    gtk_widget_set_hexpand(content_box, TRUE);
    gtk_widget_set_vexpand(content_box, TRUE);

    // create the stack for navigation
    GtkWidget *stack = gtk_stack_new();
    gtk_stack_set_transition_type(GTK_STACK(stack), GTK_STACK_TRANSITION_TYPE_SLIDE_LEFT_RIGHT);
    gtk_stack_set_transition_duration(GTK_STACK(stack), 300);
    gtk_widget_set_hexpand(stack, TRUE);
    gtk_widget_set_vexpand(stack, TRUE);

    // add the headerbar
    GtkWidget *headerbar = create_custom_headerbar(stack);
    gtk_widget_set_halign(headerbar, GTK_ALIGN_START);
    gtk_widget_set_valign(headerbar, GTK_ALIGN_START);
    gtk_box_append(GTK_BOX(content_box), headerbar);

    // add the stack to the main box
    gtk_box_append(GTK_BOX(content_box), stack);

    // create a new home page 
    // used for other widgets
    GtkWidget *home_page = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8);

    // add a status label
    status_label = gtk_label_new(_("Searching for updates..."));
    gtk_box_append(GTK_BOX(home_page), status_label);

    // create a new progress bar
    progress_bar = gtk_progress_bar_new();
    gtk_progress_bar_set_show_text(GTK_PROGRESS_BAR(progress_bar), TRUE);
    gtk_box_append(GTK_BOX(home_page), progress_bar);

    // add the update info frame
    create_update_info_widgets(home_page);

    // other buttons
    // TODO: lack of usability for non-developers and lack of configuration options for the updater 
    check_button = gtk_button_new_with_label(_("Search for Updates"));
    g_signal_connect(check_button, "clicked", G_CALLBACK(on_check_clicked), NULL);
    gtk_box_append(GTK_BOX(home_page), check_button);

    download_button = gtk_button_new_with_label(_("Download (--download)"));
    g_signal_connect(download_button, "clicked", G_CALLBACK(on_download_clicked), NULL);
    gtk_box_append(GTK_BOX(home_page), download_button);

    install_button = gtk_button_new_with_label(_("Install (--install)"));
    g_signal_connect(install_button, "clicked", G_CALLBACK(on_install_clicked), NULL);
    gtk_box_append(GTK_BOX(home_page), install_button);

    full_button = gtk_button_new_with_label(_("Everything (--full)"));
    g_signal_connect(full_button, "clicked", G_CALLBACK(on_full_clicked), NULL);
    gtk_box_append(GTK_BOX(home_page), full_button);

    // add the home page to the stack
    gtk_stack_add_named(GTK_STACK(stack), home_page, "home_page");
    gtk_stack_set_visible_child_name(GTK_STACK(stack), "home_page");

    // show the main window
    gtk_window_present(GTK_WINDOW(window));

    // automatic for updates at the start 
    run_to_updater("--check");
    update_labels_from_config();

    // cloas the logging
    close_logging();
}

