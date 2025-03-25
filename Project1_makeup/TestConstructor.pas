program TestConstructor;
class MyClass;
public
  var a: integer;
  constructor;
  begin
    a := 123;
  end;
end;
begin
  var obj := MyClass();
  writeln(obj.a);
end.