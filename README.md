# This repository has been moved to [Codeberg](https://codeberg.org/SamMatzko/luanti-subways).
# [Minetest](https://minetest.net/) Subways - [ContentDB](https://content.minetest.net/packages/sylvester_kruin/subways/)

[![ContentDB](https://content.minetest.net/packages/sylvester_kruin/subways/shields/downloads/)](https://content.minetest.net/packages/sylvester_kruin/subways/)

This mod aims to add several unique, real-world subway trains to Minetest's Advanced Trains. New trains will be worked on when I have the time, you can see the [open GitHub issues](https://github.com/SamMatzko/minetest-subways/issues) for a list of the trains that will be added.

> [!WARNING]
> Unfortunately, the 2.x update brings breaking changes. If you have a pre-2.x version installed, be aware that the new subway trains have different names, so any existing Green Subway Wagon or Red Subway Wagon trains will no longer appear correctly.

> [!NOTE]
> Aliases have now been registered for backwards compatibility with 1.x. However, for the feature to work, you need to use the [AdvTrains patch "Alias for wagon types"](https://lists.sr.ht/~gpcf/advtrains-devel/patches/54786).
>
> The displays are now set using the first line of the "Outside Text" field.

## Features
Here are some features that Subways 2 brings:
- Support for [AdvTrains Livery Tools](https://content.minetest.net/packages/Marnack/advtrains_livery_tools/)
- Exterior displays with expansive Unicode support
- Removal of development assets to a [different repository](https://github.com/SamMatzko/minetest-subways-dev-assets) to reduce package size

## Usage
### Setting the train color
This mod supports [AdvTrains Livery Tools](https://content.minetest.net/packages/Marnack/advtrains_livery_tools/). To change the color of a subway car, punch it with the Livery Designer Tool.

### Setting the outside display text
The outside displays now show the first line of text from the "Outside Text" field. Version 2.x has [unicode_text](https://content.minetest.net/packages/erlehmann/unicode_text/) support, so thousands of Unicode characters can be used. Just enter the driver stand, select "Onboard Computer," and type in the "Outside Text" text box, as you would for any AdvTrains train.

## Have any ideas and/or contributions?

If you have any ideas for more subways to be added, feel free to [open an issue on GitHub](https://github.com/SamMatzko/minetest-subways/issues/new/choose). Bear in mind that I'm still in school, so I'll have limited time during the academic year to work on new trains.

If you have a modification you've made and you'd like to submit it, you're welcome to [open a pull request](https://github.com/SamMatzko/minetest-subways/compare).

Development assets for this repository are stored at [minetest-subways-dev-assets](https://github.com/SamMatzko/minetest-subways-dev-assets).

## Licenses
The code is licensed under the [AGPL-3.0](https://github.com/SamMatzko/minetest-subways/blob/master/LICENSE.txt); all media (3D files, image textures, etc.) is licensed under [CC-BY-SA-3.0](http://creativecommons.org/licenses/by-sa/3.0/).
