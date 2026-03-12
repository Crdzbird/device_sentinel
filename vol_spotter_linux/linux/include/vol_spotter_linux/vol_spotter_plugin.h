#ifndef FLUTTER_PLUGIN_VOL_SPOTTER_LINUX_PLUGIN_H_
#define FLUTTER_PLUGIN_VOL_SPOTTER_LINUX_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

G_DECLARE_FINAL_TYPE(FlVolSpotterPlugin, fl_vol_spotter_plugin, FL,
                     VOL_SPOTTER_PLUGIN, GObject)

FLUTTER_PLUGIN_EXPORT FlVolSpotterPlugin* fl_vol_spotter_plugin_new(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT void vol_spotter_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_VOL_SPOTTER_LINUX_PLUGIN_H_