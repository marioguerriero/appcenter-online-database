// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE

  Copyright (C) 2013      Mario Guerriero <mario@elementaryos.org>
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as
  published    by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program.  If not, see <http://www.gnu.org/licenses>

  END LICENSE
***/

// valac --pkg=libsoup-2.4 --pkg=json-glib-1.0 appcenter.vala

using Soup;
using Json;

namespace AppCenter {
    
    public class AppInfo : GLib.Object {
        
        public string name;
        public string id;
        public string category;
        public string version;
        public string summary;
        public string description;
        public int64 rating;
        public string icon;
        public string price;
        public string author;
        public string website;
        public string license;
        public string[] screenshots;
        
        public AppInfo.from_json (Json.Object json) {
            this.name = json.get_string_member ("name");
            
            stdout.printf (name + "\n");
        }
    }
    
    public class DatabaseClient : GLib.Object {
    
        private const string HOST = "http://127.0.0.1";
        
        private const string APPS_BUCKET = "apps";
        private const string REVIEWS_BUCKET = "reviews";
        
        public static AppInfo? get_app_info (string id) {
            // Soup query
            var session = new Soup.SessionSync ();
            var message = new Soup.Message ("GET", HOST + ":8092/apps/_design/dev_apps/_view/apps?key=\"%s\"".printf(id));

            session.send_message (message);
            
            // JSON parsing
            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                    
                var root_object = parser.get_root ().get_object ();
                
                foreach (var node in root_object.get_array_member ("rows").get_elements ()) {
                    var object = node.get_object ();
                    
                    var app_json = object.get_object_member ("value");
                    return new AppInfo.from_json (app_json);
                }
            } catch (Error e) { 
                warning (e.message);
                return null;
            }
            
            return null; 
        }
        
        public static Gee.ArrayList<AppInfo> get_apps_from_category (string category) {
            // Soup query
            var session = new Soup.SessionSync ();
            var message = new Soup.Message ("GET", HOST + ":8092/apps/_design/dev_category/_view/category?key=\"%s\"".printf(category));

            session.send_message (message);
            
            Gee.ArrayList<AppInfo> list = new Gee.ArrayList<AppInfo> ();
            
            // JSON parsing
            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                    
                var root_object = parser.get_root ().get_object ();
                
                foreach (var node in root_object.get_array_member ("rows").get_elements ()) {
                    var object = node.get_object ();
                    
                    var app_json = object.get_object_member ("value");
                    list.add (new AppInfo.from_json (app_json));
                }
            } catch (Error e) { 
                warning (e.message);
            }
            
            return list; 
        }
        
    }

}

void main () {
    AppCenter.DatabaseClient.get_app_info ("appcenter");
    AppCenter.DatabaseClient.get_apps_from_category ("utilities");
}
