

import 'dart:io';

void logSuccess(String message) {
  print('\x1B[32m✅ $message\x1B[0m'); // Vert
}

void logWarning(String message) {
  print('\x1B[33m⚠️ $message\x1B[0m'); // Jaune
}

void logError(String message) {
  print('\x1B[31m❌ $message\x1B[0m'); // Rouge
}

void logInfo(String message) {
  print('\x1B[34mℹ️ $message\x1B[0m'); // Bleu
}


String? readInput(String input) {
  logInfo(input);
  return stdin.readLineSync()?.trim();
}

const String featuresBasePath = 'lib/src/features';

//------------------ State Management ------------------ 
//: Changer la valeur de stateManagement par rapport au state management que vous utilisez
final String stateManagement ='riverpod';

void createFeatureStructure(String featureName){
  final featureNameNorm = featureName.toSnakeCase();
  final folders = [
    '$featuresBasePath/$featureNameNorm/data',
    '$featuresBasePath/$featureNameNorm/data/datasources',
    '$featuresBasePath/$featureNameNorm/data/models',
    '$featuresBasePath/$featureNameNorm/data/repositories',

    '$featuresBasePath/$featureNameNorm/domain',
    '$featuresBasePath/$featureNameNorm/domain/entities',
    '$featuresBasePath/$featureNameNorm/domain/repositories',
    '$featuresBasePath/$featureNameNorm/domain/usecases',

    '$featuresBasePath/$featureNameNorm/presentation',
    '$featuresBasePath/$featureNameNorm/presentation/pages',
    '$featuresBasePath/$featureNameNorm/presentation/widgets',
  ];

  switch(stateManagement){
    case 'riverpod':
      folders.add('$featuresBasePath/$featureNameNorm/presentation/providers');
      break;
    case 'bloc':
      folders.add('$featuresBasePath/$featureNameNorm/presentation/bloc');
      break;
    case 'getx':
      folders.add('$featuresBasePath/$featureNameNorm/presentation/controllers');
      break;
  }

  for (var folder in folders) {
    final directory = Directory(folder);
    if (directory.existsSync()) {
      logWarning('Le dossier $folder existe deja');
    } else {
      directory.createSync(recursive: true);
      logSuccess('Le dossier $folder a ete cree');
    }
  }

}

void createFiles(String featureName) {
  final featureNameNorm = featureName.toSnakeCase();
  final files = {
    '$featuresBasePath/$featureNameNorm/domain/repositories/${featureNameNorm}_repository.dart': null,
    '$featuresBasePath/$featureNameNorm/domain/usecases/get_${featureNameNorm}_usecase.dart': null,
    '$featuresBasePath/$featureNameNorm/data/datasources/${featureNameNorm}_remote_data_source.dart': null,
    '$featuresBasePath/$featureNameNorm/data/datasources/${featureNameNorm}_local_data_source.dart': null,
    '$featuresBasePath/$featureNameNorm/data/models/${featureNameNorm}_model.dart': null,
    '$featuresBasePath/$featureNameNorm/data/repositories/${featureNameNorm}_repository_impl.dart': null,
    '$featuresBasePath/$featureNameNorm/presentation/pages/${featureNameNorm}_page.dart': null,
    '$featuresBasePath/$featureNameNorm/presentation/widgets/${featureNameNorm}_widget.dart': null,
  };

  switch (stateManagement) {
    case 'riverpod':
      files['$featuresBasePath/$featureNameNorm/presentation/providers/${featureNameNorm}_provider.dart'] = null;
      break;
    case 'bloc':
      files['$featuresBasePath/$featureNameNorm/presentation/bloc/${featureNameNorm}_bloc.dart'] = null;
      break;
    case 'getx':
      files['$featuresBasePath/$featureNameNorm/presentation/controllers/${featureNameNorm}_controller.dart'] = null;
      break;
  }

  for (var filePath in files.keys) {
    final file = File(filePath);
    if (file.existsSync()) {
      logWarning('Le fichier $filePath existe déjà');
    } else {
      file.createSync(recursive: true);
      logSuccess('Le fichier $filePath a été créé');
    }
  }
}


extension NormalizeExtension on String {
  String toSnakeCase() {
    final RegExp upperCasePattern = RegExp(r'[A-Z]');
    return replaceAllMapped(upperCasePattern, (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '') 
        .replaceAll(RegExp(r'_+'), '_');
  }


  String toPascalCase() {
    return split(RegExp(r'[_\s]+')) 
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
        .join('');
  }
}

void addContentToFiles(String featureName) {
  final featureNameNorm = featureName.toSnakeCase();
  final className = featureName.toPascalCase();

  final filesContent = {
    '$featuresBasePath/$featureNameNorm/domain/repositories/${featureNameNorm}_repository.dart': '''
abstract class ${className}Repository {
}
''',
    '$featuresBasePath/$featureNameNorm/domain/usecases/get_${featureNameNorm}_usecase.dart': '''

class Get${className}UseCase {
 
}
''',
    '$featuresBasePath/$featureNameNorm/data/datasources/${featureNameNorm}_remote_data_source.dart': '''

class ${className}RemoteDataSource {
}
''',
    '$featuresBasePath/$featureNameNorm/data/datasources/${featureNameNorm}_local_data_source.dart': '''

class ${className}LocalDataSource {
}
''',
    '$featuresBasePath/$featureNameNorm/data/models/${featureNameNorm}_model.dart': '''
class ${className}Model {
}
''',
    '$featuresBasePath/$featureNameNorm/data/repositories/${featureNameNorm}_repository_impl.dart': '''

import '../../domain/repositories/${featureNameNorm}_repository.dart';
class ${className}RepositoryImpl implements ${className}Repository {
 
}
''',
};

  for (var filePath in filesContent.keys) {
    final file = File(filePath);
    if (file.existsSync()) {
      file.writeAsStringSync(filesContent[filePath]!);
      logSuccess('Le contenu a été ajouté dans le fichier $filePath');
    } else {
      logWarning('Le fichier $filePath n\'existe pas');
    }
  }
  
  }

void main() {
  int? featureCount;

  while(featureCount == null || featureCount <= 0) {
    featureCount = int.tryParse(readInput('''Combien de features 
    voulez vous creer: ''')!);
    if (featureCount == null || featureCount <= 0) {
      logError("Le nombre de features doit etre superieur a 0");
    }
  }

  for(int i = 1; i <= featureCount; i++) {
    String? featureName;
    while(featureName == null || featureName.isEmpty) {
      featureName = readInput('''Entrer le nom du feature $i:
      (en snake_case si c'est en plusieurs mots, ex : rental_listing)''');
      if (featureName == null || featureName.isEmpty) {
        logError("Le nom du feature est requis");
      }
    }
    createFeatureStructure(featureName);
    createFiles(featureName);
    addContentToFiles(featureName);
  }
}