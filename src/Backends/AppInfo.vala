/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */

public class Backend.AppInfo : Object {

    private uint refresh_timer_id = 0;
    private int interval = 5;

    private GLib.AppInfoMonitor app_monitor;
    public Gee.HashMap<string, GLib.AppInfo> apps { get; private set; default = null; }

    construct {
        debug ("Constructing app monitor backend");
        apps = new Gee.HashMap<string, GLib.AppInfo> ();
        app_monitor = GLib.AppInfoMonitor.@get ();
        app_monitor.changed.connect (queue_app_list_update);
        update_app_list ();
    }

    private void queue_app_list_update () {
        debug ("Queueing an update to the app list");
        if (refresh_timer_id != 0) {
            GLib.Source.remove (refresh_timer_id);
        }

        refresh_timer_id = Timeout.add_seconds (interval, () => {
            refresh_timer_id = 0;
            update_app_list ();
            return GLib.Source.REMOVE;
        });

    }

    private void update_app_list () {
        debug ("Updating app list!");
        var app_list = GLib.AppInfo.get_all ();
        foreach (var app in app_list) {
            debug ("Found %s, adding to app list\n", app.get_id ());
            apps.@set (app.get_id (), app);
        }
    }

    public Gee.HashMap<string, GLib.AppInfo> simple_search (string target){
        GLib.Regex rg_target = null;
        var results = new Gee.HashMap<string, GLib.AppInfo> ();

        try {
            rg_target = new GLib.Regex ("(?i)" + target);
        } catch (RegexError err) {
            critical ("Failed to compile target regex: %s", err.message);
            return results;
        }

        foreach (var app in apps) {
            var key = app.key;
            var d_name = app.value.get_display_name ();

            if (rg_target.match (key) || rg_target.match (d_name)) {
                results.set (app.key, app.value);
            }
        }

        return results;
    }
}
