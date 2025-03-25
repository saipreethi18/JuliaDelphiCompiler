program TestInheritance;
class Parent;
public
  var p: integer;
  constructor;
  begin
    p := 10;
  end;
end;
class Child inherits Parent;
public
  var c: integer;
  constructor;
  begin
    c := 20;
  end;
end;
begin
  var obj := Child();
  writeln(obj.p, ' ', obj.c);
end.