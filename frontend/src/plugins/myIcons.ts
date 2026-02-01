// search for icons at https://pictogrammers.com/library/mdi/ and put their names here:
import { mdiDeleteForever, mdiMapMarker } from "@mdi/js";

// here you can tell the Programm how to name those Icons now
// you can now access them using the vuitify icon component and $[name] for example $marker will draw the mdiMapMarker
// example:     <v-icon      color="primary"      icon="$marker"      size="large"      variant = "plain"    ></v-icon>
// by default some aliasses are already defined, you can check out the docs here: https://vuetifyjs.com/en/features/icon-fonts/#icon-aliases
export const customIcons: Record<string, string> = {
  marker: mdiMapMarker,
  trashcan: mdiDeleteForever,
};
