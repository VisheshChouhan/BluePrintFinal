import 'dart:collection';

class CustomMap extends MapBase<String, dynamic> {
  final Map<String, dynamic> _innerMap;

  CustomMap([Map<String, dynamic>? other]) : _innerMap = Map<String, dynamic>.from(other ?? {});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is CustomMap && _mapsAreEqual(_innerMap, other._innerMap);
  }

  @override
  int get hashCode => _mapHashCode(_innerMap);

  bool _mapsAreEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (String key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }

  int _mapHashCode(Map<String, dynamic> map) {
    int hash = 0;
    map.forEach((key, value) {
      hash = hash ^ key.hashCode ^ value.hashCode;
    });
    return hash;
  }

  @override
  dynamic operator [](Object? key) => _innerMap[key];

  @override
  void operator []=(String key, dynamic value) {
    _innerMap[key] = value;
  }

  @override
  void clear() => _innerMap.clear();

  @override
  Iterable<String> get keys => _innerMap.keys;

  @override
  dynamic remove(Object? key) => _innerMap.remove(key);

  @override
  String toString() => _innerMap.toString();

  Map<String, dynamic> getInnerMap(){
    return _innerMap;
  }
}