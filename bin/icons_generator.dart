// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// TODO: WeatherIcons.json to .dart (hx to int)

/// Execute the generator to create the icon classes:
/// ```sh
/// dart lib/generator/main.dart
/// ```
///
void main() {
  final normalList = _getListJson(TypeFont.normal);

  print('Please Create the nexts methods in the NewFlutterIconData class:');

  for (final element in normalList) {
    _convertNormalFont2Json(element);
  }

  final withMetaList = _getListJson(TypeFont.with_meta);

  _whitMetaJson(withMetaList);
}

const _dir = 'bin/icons';

void _whitMetaJson(List<String> withMetaList) {
  final metaList =
      withMetaList.where((element) => element.contains('_meta.json'));

  final fontList =
      withMetaList.where((element) => !element.contains('_meta.json'));

  for (final pathJson in fontList) {
    final pathMetajson = metaList.firstWhere(
      (meta) => meta.contains(_jsonStringName(pathJson)),
    );

    _convertMetaFont2Json(jsonFontMeta: pathMetajson, jsonFont: pathJson);
  }
}

void _convertNormalFont2Json(String jsonFilePath) {
  final jsonFile = File(jsonFilePath);

  final jsonFileName = _jsonFileName(jsonFile);

  final Map<String, dynamic> jsonMap = json.decode(jsonFile.readAsStringSync());

  _normalFontFile(jsonFileName: jsonFileName, jsonMap: jsonMap);
}

void _convertMetaFont2Json(
    {required String jsonFontMeta, required String jsonFont}) {
  final jsonFile = File(jsonFont);

  final jsonMetaFile = File(jsonFontMeta);

  final jsonFileName = _jsonFileName(jsonFile);

  final Map<String, dynamic> gly = json.decode(jsonMetaFile.readAsStringSync());

  final Map<String, dynamic> jsonMap = json.decode(jsonFile.readAsStringSync());

  final List<String> keys = gly.keys.toList();

  for (final key in keys) {
    _withMetaFontFile(
      jsonFileName: jsonFileName,
      keyType: key,
      jsonMap: jsonMap,
      metaMap: gly,
    );
  }
}

void _withMetaFontFile({
  required String jsonFileName,
  required String keyType,
  required Map<String, dynamic> jsonMap,
  required Map<String, dynamic> metaMap,
}) {
  final keyName =
      keyType.toLowerCase() == 'regular' ? '' : '_${keyType.capitalize()}';

  final newFileName = "$jsonFileName$keyName";

  final buffer = _createHeaderCode(newFileName);

  final List obj = metaMap[keyType];

  for (var iconName in obj) {
    final unicode = jsonMap[iconName];
    buffer.writeln(
        "  static const IconData ${_correctFormat(iconName)} = NewFlutterIconData.${_toCamelCase(newFileName)}($unicode);");
  }
  buffer.writeln("}");

  final dartFile = File('$_dir/${_toSnakeCase(newFileName)}.dart');

  dartFile.writeAsStringSync(buffer.toString());

  print(
    'const NewFlutterIconData.${_toCamelCase(newFileName)}(int codePoint) : this(codePoint, "$newFileName");',
  );
}

void _normalFontFile(
    {required String jsonFileName, required Map<String, dynamic> jsonMap}) {
  final buffer = _createHeaderCode(jsonFileName);
  jsonMap.forEach((iconName, unicode) {
    buffer.writeln(
        "  static const IconData ${_correctFormat(iconName)} = NewFlutterIconData.${_toCamelCase(jsonFileName)}($unicode);");
  });
  buffer.writeln("}");

  final dartFile = File('$_dir/${_toSnakeCase(jsonFileName)}.dart');

  dartFile.writeAsStringSync(buffer.toString());

  print(
    'const NewFlutterIconData.${_toCamelCase(jsonFileName)}(int codePoint) : this(codePoint, "$jsonFileName");',
  );
}

StringBuffer _createHeaderCode(String jsonFileName) {
  final buffer = StringBuffer();

  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import '../new_flutter_icon_data.dart';");
  buffer.writeln();
  buffer.write(_comments(jsonFileName));
  buffer.writeln("abstract class ${_toPascalCase(jsonFileName)} {");

  return buffer;
}

String _toCamelCase(String text) {
  final parts = text.split('_');
  final capitalized = parts.map((word) => word.capitalize());
  final str = capitalized.join();

  return str[0].toLowerCase() + str.substring(1);
}

String _toPascalCase(String text) {
  final camelCase = _toCamelCase(text);
  return camelCase.capitalize();
}

String _toSnakeCase(String text) {
  final str = _toCamelCase(text);
  return str.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
    return '_${match.group(0)}';
  }).toLowerCase();
}

String _correctFormat(String text) {
  final str = text.replaceAll('-', '_');
  // check if is a keyword or number
  if (str.startsWith(RegExp(r'[0-9]')) || _keyWords.contains(str)) {
    return "\$$str";
  }
  return str;
}

// String _toName(String text) {
//   final str = _toCamelCase(text);
//   return str.substring(0, 1).toLowerCase() + str.substring(1);
// }

String _jsonFileName(File file) => _jsonStringName(file.path);

String _jsonStringName(String path) => path.split('/').last.split('.').first;

List<String> _getListJson(TypeFont type) {
  final directory = Directory('bin/glphmaps/${type.name}');

  final List<String> list = [];

  directory.listSync().forEach((element) {
    if (element is File) {
      list.add(element.path);
    }
  });

  return list;
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

enum TypeFont {
  normal,
  with_meta,
}

String _comments(String text) {
  final url = _urlMap[text];
  return url != null
      ? """
  /// All Icons under [$text]
  /// 
  /// [$url]
  """
      : '';
}

Map<String, String> _urlMap = {
  "AntDesign": "https://ant.design/",
  "Entypo": "https://entypo.com/",
  "EvilIcons": "https://evil-icons.io/",
  "Feather": "https://feathericons.com/",
  "FontAwesome": "https://fortawesome.github.io/Font-Awesome/icons",
  "FontAwesome5": "https://fontawesome.com/v5/icons/",
  "FontAwesome5_Brands": "https://fontawesome.com/v5/icons/",
  "FontAwesome5_Solid": "https://fontawesome.com/v5/icons/",
  "FontAwesome6": "https://fontawesome.com",
  "FontAwesome6_Brands": "https://fontawesome.com",
  "FontAwesome6_Solid": "https://fontawesome.com",
  "Fontisto": "https://github.com/kenangundogan/fontisto",
  "Foundation": "https://zurb.com/playground/foundation-icon-fonts-3",
  "Ionicons": "https://ionicons.com/",
  "MaterialCommunityIcons": "https://materialdesignicons.com/",
  "MaterialIcons": "https://fonts.google.com/icons/",
  "Octicons": "https://octicons.github.com",
  "SimpleLineIcons": "https://simplelineicons.github.io/",
  "Zocial": "https://zocial.smcllns.com/",
  "WeatherIcons": "https://erikflowers.github.io/weather-icons/",
};

List<String> _keyWords = [
  "class",
  "abstract",
  "as",
  "assert",
  "async",
  "await",
  "break",
  "case",
  "catch",
  "new",
  "const",
  "continue",
  "default",
  "do",
  "else",
  "enum",
  "extends",
  "false",
  "final",
  "finally",
  "for",
  "if",
  "in",
  "is",
  "late",
  "rethrow",
  "return",
  "super",
  "switch",
  "this",
  "throw",
  "true",
  "try",
  "var",
  "void",
  "while",
  "with",
  "yield",
  "null",
];
