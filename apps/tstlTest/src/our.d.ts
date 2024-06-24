/** @noSelf **/
declare interface json extends LuaTable {
  /** @noSelf **/
  encode: (obj: LuaTable | any[]) => string;
  /** @noSelf **/
  decode: (str: string) => LuaTable;
}


/** @noSelf **/
declare interface helper extends LuaTable {
  /** @noSelf **/
  printlnColoredString: (str: string) => string;
}


