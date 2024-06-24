export class Testing {
  static readonly myvar = 'hello';
  constructor() {
    print('hello from constructor' + os.time());
  }

  static myfunc() {
    print('hello from myfunc');
  }
}
