/*
* updater.c
*
* (C) Copyright 2025 AtlantisOS Project
* by @NachtsternBuild
*
* License: GNU GENERAL PUBLIC LICENSE Version 3
*
* Usage:
* ./updater
*
* Notes:
* This works only in the ecosystem of atlantis os
* To test the UI use the test.sh instead of updater.sh 
* This are only the startup function for GTK4 and libadwaita
*/

#include <glib.h>
#include <gtk/gtk.h>
#include <adwaita.h>
#include "design.h"
#include "updater.h"

// define the local domian
const char *LOCALE_DOMAIN = "atl-updater";

// main function
int main(int argc, char *argv[]) 
{
	g_autoptr(AdwApplication) app = NULL;

    app = adw_application_new("io.github.atlantisos.updater", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK (activate_updater), NULL);

    return g_application_run(G_APPLICATION (app), argc, argv);
}

