program Trans;

uses
  Forms,
  TransUnit in 'TransUnit.pas' {TransForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTransForm, TransForm);
  Application.Run;
end.
