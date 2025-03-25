program TestConstructorDestructor;
class MyClass;
public
  var a: integer;
  constructor;
  begin
    a := 789;
  end;
  destructor;
  begin
    writeln('Destructor called');
  end;
end;
begin
  var obj := MyClass();
  writeln('a = ', obj.a);
  obj.destructor();  // Explicit destructor call for testing
end.