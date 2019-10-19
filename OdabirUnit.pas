unit OdabirUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  TOdabirForm = class(TForm)
    ListBox1: TListBox;
    StatusBar1: TStatusBar;
    ListBox2: TListBox;
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    ModRes: Boolean;
    Odabir, Odabir_Sifra: String;
    { Public declarations }
  end;

var
  OdabirForm: TOdabirForm;

implementation

{$R *.DFM}

procedure TOdabirForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = 13 then
     begin
          Odabir := ListBox1.Items[ListBox1.ItemIndex];
          Odabir_Sifra := ListBox2.Items[ListBox1.ItemIndex];
          ModRes := True;
          OdabirForm.Close;
     end
     else if Key = 27 then OdabirForm.Close;
end;

procedure TOdabirForm.ListBox1DblClick(Sender: TObject);
begin
     Odabir := ListBox1.Items[ListBox1.ItemIndex];
     Odabir_Sifra := ListBox2.Items[ListBox1.ItemIndex];
     ModRes := True;
     OdabirForm.Close;
end;

end.
