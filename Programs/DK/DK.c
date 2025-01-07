#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

void AddModulesPath(lua_State* L, const char* Path) {
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "path");
  lua_pushstring(L, ";./");
  lua_pushstring(L, Path);
  lua_pushstring(L, "/?.lua");
  lua_concat(L, 4);
  lua_setfield(L, -2, "path");
  lua_pop(L, 1);
}

bool LoadScript(lua_State* L, const char* Path, bool bDebug) {
  if(luaL_dofile(L, Path) != LUA_OK) {
    printf("[ERROR] Script not loaded => %s\n", ((bDebug) ? lua_tostring(L, -1) : ""));
    return false;
  }
  return true;
}

int main(int argc, const char** argv) {
  lua_State* L = NULL;
  L = luaL_newstate();
  luaL_openlibs(L);
  AddModulesPath(L, "Programs/Modules");
  AddModulesPath(L, "Programs/DK/Modules");
  argv++;

  lua_getglobal(L, "require");
  lua_pushstring(L, "Bootstrap");
  lua_call(L, 1, 1);

  printf("Developmet Kit\n");
  lua_getglobal(L, "Init");
  lua_newtable(L);

  for(int i = 0; i < argc; i++) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i + 1);
  }

  lua_pcall(L, 1, 0, 0);
  lua_close(L);
}
