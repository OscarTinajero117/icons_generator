# Icons Generator

## Instructions

1. You need to get the json file with the information of font (name and icon code).
2. If the json file have 2 parts (meta and font information), add the json files in `bin/glphmaps/with_meta` folder; if only have 1 part, add it in `bin/glphmaps/normal`.
3. Run the generator:

    ```bash
    dart bin/icons_generator.dart
    ```

Now, cut the files in `bin/icons` and paste in the correct project (new_flutter_icons) directory.
