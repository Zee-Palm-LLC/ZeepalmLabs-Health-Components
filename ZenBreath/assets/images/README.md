# Artwork

Only one image is bundled: `welcome_bg.jpg`, the sunrise lake used behind the
welcome headline. It ships locally because the glowing orb in the centre of that
photograph is part of the brand mark rather than decoration.

Every other photograph streams from Unsplash and is declared in
`lib/data/app_data.dart` (`AppImages` and `kMeditations`):

| Slot | Subject in the reference |
| --- | --- |
| `AppImages.homeHeader` | Hazy lake and mountains behind the greeting |
| `AppImages.avatar` | Portrait for the greeting bar and profile |
| `AppImages.quickStart` | Small crop of the lake for the Quick Start tile |
| Anxiety Relief | Stillness / meditation |
| Deep Sleep | Night sky over dark ridges |
| Focus | Layered blue mountains |
| Relaxation | Sunset over water |
| Morning Energy | Sunrise over hills |
| Stress Reset | Sunlit forest |

`AppImage` paints the tonal gradient declared next to each usage while a remote
image loads, and keeps it permanently if the request fails - so the layout never
collapses on a slow or offline device. To pin the artwork instead, drop files
into this folder and point the constants at the asset paths; `pubspec.yaml`
already declares the whole directory.

Android needs `android.permission.INTERNET` for the remote images; it is already
in `android/app/src/main/AndroidManifest.xml`.
