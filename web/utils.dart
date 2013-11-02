library utils;

const int mask29 = 0x1fffffff;

int jHash(List<Object> objects) {
  int hash = 0;
  for (int i = 0; i < objects.length; i++) {
    hash = mask29 & (hash + objects[i]);
    hash = mask29 & (hash + ((0x7ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  hash = mask29 & (hash + ((0x3ffffff & hash) <<  3));
  hash ^= hash >> 11;
  return mask29 & (hash + ((0x3fff & hash) << 15));
}
