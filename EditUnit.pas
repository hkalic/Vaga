unit EditUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, dxCntner, dxEditor, dxEdLib;

type
  TEditForm = class(TForm)
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    ComboBox1: TComboBox;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    Panel1: TPanel;
    Edit4: TEdit;
    Label5: TLabel;
    SpeedButton1: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    Edit5: TEdit;
    Label8: TLabel;
    ComboBox2: TComboBox;
    Label9: TLabel;
    Label11: TLabel;
    Edit7: TdxEdit;
    Edit6: TEdit;
    Label10: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Edit3KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Edit6Exit(Sender: TObject);
  private
    { Private declarations }
  public
    ModRes: Boolean;
    { Public declarations }
  end;

var
  EditForm: TEditForm;

implementation

uses DataUnit, PojamUnit, MainUnit;

{$R *.DFM}

procedure TEditForm.FormShow(Sender: TObject);
begin
     if Data.Act = 'Edit' then Edit1.ReadOnly := True
     else Edit1.ReadOnly := False;
     ModRes := False;
     Panel1.Caption := IntToStr( 100-Length(Edit3.Text) );
     ActiveControl := Edit1;
end;

procedure TEditForm.Edit3KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     Panel1.Caption := IntToStr( 100-Length(Edit3.Text) );
end;

procedure TEditForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = VK_F1 then
        ShowMessage( 'Znaèenje polja:'+#13#13#10+
                     'PLU: interna šifra artikla za vage.'+#13#10+
                     'Šifra: robna šifra artikla.'+#13#10+
                     'Grupa: robna grupa.'+#13#10+
                     'Naziv: naziv artikla, max 100 znakova.'+#13#10+
                     'Broj: broj za programabilne vage.'+#13#10+
                     'Rok tr.: unos broja dana trajanja (od vaganja) za robu koju mi pakiramo.'+#13#10+
                     'JM: jedinica mjere, odnosno roba se prodaje komadno ili kolièinski.'+#13#10+
                     'Cijena: trenutna cijena artikla na '+skladiste+' skladištu' )
     else if Key = 27 then EditForm.Close;
end;

procedure TEditForm.BitBtn1Click(Sender: TObject);
begin
     if (Edit1.Text <> '') and (Edit2.Text <> '') and (Edit3.Text <> '') and (ComboBox1.Text <> '') then
     begin
          try StrToInt( Edit1.Text );
          except
                ShowMessage( 'Unešeni PLU nije broj...' );
                ActiveControl := Edit1;
                Exit;
          end;
          if Edit5.Text <> '' then
          begin
               try StrToInt( Edit5.Text );
               except
                     ShowMessage( 'Unešena vrijednost roka trajanja (broj dana) nije broj...' );
                      ActiveControl := Edit5;
                     Exit;
               end;
               if StrToInt( Edit5.Text ) = 0 then Edit5.Text := '';
          end;
          if Data.Act = 'New' then
          begin
               Data.UpitOpen( Data.Upit2, ' select plu from '+baza+'.dbo.vaga_artikal where plu="'+Edit1.Text+'" and ean<>"999999"' );
               if not Data.Upit2.Fields[0].IsNull then
               begin
                    ShowMessage( 'PLU veæ postoji...' );
                    ActiveControl := Edit1;
                    Exit;
               end;
               Data.UpitOpen( Data.Upit2, ' select ean from '+baza+'.dbo.vaga_artikal where ean="'+Edit2.Text+'"' );
               if not Data.Upit2.Fields[0].IsNull then
               begin
                    ShowMessage( 'Šifra artikla veæ postoji...' );
                    ActiveControl := Edit2;
                    Exit;
               end;
          end;
          ModRes := True;
          EditForm.Close;
     end
     else ShowMessage( 'Unesite sve parametre...' );
end;

procedure TEditForm.SpeedButton1Click(Sender: TObject);
begin
     PojamForm.Edit1.Clear;
     PojamForm.ShowModal;
     if PojamForm.ModRes then
     begin
          Data.Daj_Dodaj_Grupu( PojamForm.Edit1.Text );
          ActiveControl := ComboBox1;
     end;
end;

procedure TEditForm.Edit6Exit(Sender: TObject);
begin
     if Data.act='New' then Edit7.Text:=Data.DajCijenu(Edit6.Text,3);
end;

end.
