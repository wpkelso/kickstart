/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */


const string APP_ID = "io.github.wpkelso.kickstart";

public class Application : Gtk.Application {

    public Application () {
        Object (
                application_id: APP_ID,
                flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    public override void startup () {
        Granite.init ();
        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
                                                          granite_settings.prefers_color_scheme == DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                                                              granite_settings.prefers_color_scheme == DARK
            );
        });

        SimpleAction quit_action = new SimpleAction ("quit", null);
        set_accels_for_action ("app.quit", {"<Control>q"});
        add_action (quit_action);
        quit_action.activate.connect (() => {
            foreach (var window in this.get_windows ()) {
                window.close_request ();
            }
            this.quit ();
        });
    }

    protected override void activate () {
        var app_window = new AppWindow ();

        add_window (app_window);
        app_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
