/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */

public class Backend.AppInfo : Object {

    private uint refresh_timer_id = 0;
    private int interval = 5;

    private GLib.AppInfoMonitor app_monitor;
    public Gee.HashMap<string, List<DesktopAppInfo>> apps { get; private set; default = null; }

    construct {
        debug ("Constructing app monitor backend");
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
            print ("%s\n", app.get_name ());
        }
    }
}
