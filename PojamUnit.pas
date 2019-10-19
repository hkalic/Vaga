unit PojamUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TPojamForm = class(TForm)
    Panel1: TPanel;
    Edit1: TEdit;
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    ModRes: Boolean;
    { Public declarations }
  end;

var
  PojamForm: TPojamForm;

implementation

{$R *.DFM}


procedure TPojamForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     ModRes := False;
     if ( Key = 13 ) and ( Edit1.Text <> '' ) then
     begin
          ModRes := True;
          Close;
     end;
     if Key = 27 then Close;
end;

end.
