program TestEncapsulation;
class Person;
public
  var name: string;
  var age: integer;
private
  var ssn: integer;  { Private member; not accessible from outside }
constructor;
begin
  name := 'Alice';
  age := 30;
  ssn := 123456;
end;
end;
begin
  var p := Person();
  writeln(p.name, ' ', p.age);
  { The following line should be disallowed by proper encapsulation rules:
  writeln(p.ssn); }
end.