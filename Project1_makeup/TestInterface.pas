program TestInterface;
interface IAnimal;
  procedure Speak;
end;
class Dog implements IAnimal;
public
  procedure Speak;
  begin
    writeln('Woof!');
  end;
end;
begin
  var pet := Dog();
  pet.Speak;
end.