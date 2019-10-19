program Libra;

uses
  ShareMem,
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  DataUnit in 'DataUnit.pas' {Data: TDataModule},
  PojamUnit in 'PojamUnit.pas' {PojamForm},
  EditUnit in 'EditUnit.pas' {EditForm},
  IspisUnit in 'IspisUnit.pas' {IspisForm},
  OdabirUnit in 'OdabirUnit.pas' {OdabirForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TData, Data);
  Application.CreateForm(TPojamForm, PojamForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TIspisForm, IspisForm);
  Application.CreateForm(TOdabirForm, OdabirForm);
  Application.Run;
end.
