program TestClass;
class MyClass;
public
  var a: integer;
  constructor;
  begin
    a := 100;
  end;
end;
begin
  var obj := MyClass();
  writeln(obj.a);
end.