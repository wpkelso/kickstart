/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */


const string APP_ID = "io.github.wpkelso.kickstart";

public class Application : Gtk.Application {
    
    Gtk.EntryBuffer buf = new Gtk.EntryBuffer ();

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

        var entry = new Gtk.Entry.with_buffer (buf) {
            primary_icon_name = "system-search-symbolic",
            placeholder_text = "Search for something…",
        };

        var window = new Gtk.Window () {
            child = entry,
            default_width = 800,
            titlebar = new Gtk.Grid (),
        };

        entry.activate.connect (on_filled_entry);

        add_window (window);
        window.present ();
    }

    public void on_filled_entry () {
        debug ("Searching for: %s", buf.get_text ());
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
