unit DataUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, DateUtils;

type
  TData = class(TDataModule)
    DB: TDatabase;
    Upit: TQuery;
    UpitSource: TDataSource;
    Upit2: TQuery;
    Cijena: TQuery;
    procedure DataCreate(Sender: TObject);
    procedure DataDestroy(Sender: TObject);
    procedure UpitAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
  public
    Prep, Upis: TStringList;
    Act, Plu, Ean, Naz, Gru, Dat1, Dat2, Rok, JM, Cij, Art, Eti: String;
    procedure SlovaConvert(s:TStringList);
    procedure UpitOpen(Query:TQuery; S:String );
    procedure UpitExec(Query:TQuery; S:TStrings );
    procedure Daj_Trazi(Sif,S:String);
    procedure Action_Insert;
    procedure Action_Edit;
    procedure Action_Delete;
    procedure Action_Print;
    procedure Action_SviPLU;
    procedure Azuriraj;
    procedure Daj_Dodaj_Grupu(S:String);
    procedure Daj_Izmjene;
    procedure Floatiraj(Query: TQuery);
    function DajCijenu(sif:String;opt:Integer):String;
    function KolikoPromjena(dat:String):String;
    function SQLDatum(dat:string):string;
    { Public declarations }
  end;

var
  Data: TData;

implementation

uses EditUnit, IspisUnit, OdabirUnit, MainUnit, PojamUnit;

{$R *.DFM}

procedure TData.UpitOpen(Query:TQuery; S:String );
begin
     Query.Close;
     Query.SQL.Clear;
     Query.SQL.Add( S );
//     ShowMessage(s);
     try
        Query.Open;
     except
        ShowMessage(s);
     end;
end;

procedure TData.UpitExec(Query:TQuery; S:TStrings );
begin
     Query.Close;
     Query.SQL.Clear;
     Query.SQL.AddStrings( S );
     try
        Query.ExecSQL;
     except
        Query.Close;
        ShowMessage(s.Text);
        Query.SQL.SaveToFile('c:\xxx.txt');
        Query.SQL.Clear;
     end;
end;

procedure TData.Floatiraj(Query: TQuery);
var I: Integer;
begin
     for I := 0 to Query.ComponentCount - 1 do
         if Query.Components[I] is TNumericField then
            if UpperCase((Query.Components[I] as TField).FieldName) = 'CIJENA'
            then ( Query.Components[I] as TNumericField ).DisplayFormat := '#,###,###,##0.00';
end;

procedure TData.DataCreate(Sender: TObject);
begin
     Prep := TStringList.Create;
     Upis := TStringList.Create;
     db.Connected := False;
     with DB.Params do
     begin
          Clear;
          Add( 'SERVER NAME='+lokalni_server);
          Add( 'database name='+godina);
          Add( 'enable bcd=True');
          Add( 'application name=Libra-'+MainForm.CurrentUserName+'@'+MainForm.CurrentComputerName);
          Add( 'user name=????'); // yeah, you wish
          Add( 'password=????');  // yeah, you wish
     end;
//     ShowMessage(db.Params.Text);
     MainForm.Caption:='Libra K+ v5.0 - '+MainForm.CurrentUserName+'@'+MainForm.CurrentComputerName+', Skladi�te='+skladiste;
     Prep.Clear;
     Prep.Add( ' SET ANSI_NULLS ON SET ANSI_WARNINGS ON');
     UpitExec( Upit, Prep);
     UpitOpen( Upit, ' select a.plu, a.ean, a.naziv_artikla, g.naziv_grupe, a.broj'+
                     ', a.rok, a.jm, cijena=a.cijena_art_u_skl, a.sifra_artikla'+
                     ' from '+baza+'.dbo.vaga_artikal a, '+baza+'.dbo.vaga_grupa g'+
                     ' where a.sifra_grupe=g.sifra_grupe'+
                     ' order by a.naziv_artikla' );
     Floatiraj(Upit);
//     ShowMessage(DateTimeToStr(IncSecond(Now,-1)));
end;

procedure TData.DataDestroy(Sender: TObject);
var F: TextFile;
    I: Integer;
begin
   Data.SlovaConvert(Data.Upis);
   if MainForm.dll.Checked then
      MainForm.Close
//      MainForm.DajDLL(Upis)
   else
   Begin
     if Upis.Text <> '' then
     begin
  {        Prep.Clear;
          Prep.Add( '0' );
          try Prep.LoadFromFile( 'c:\plup\z_upit.txt' );
          except end;
          if Prep.Strings[0] <> '0' then
          begin
               AssignFile( F, 'c:\plup\vaga.kom' );
               Append( F );
               for I := 0 to Upis.Count - 1 do Writeln( F, Upis.Strings[I] );
               CloseFile( F );
          end
          else begin
   }           Upis.SaveToFile( 'c:\plup\vaga.kom' );
//               Upis.Clear;
//               Upis.Add( '1' );
//               Upis.SaveToFile( 'c:\plup\z_upit.txt' );
//          end;
     end;
     Prep.Free;
     Upis.Free;
     Upit.Close;
     Upit2.Close;
   end;
end;

procedure TData.Daj_Trazi(Sif,S:String);
begin
     if Sif = 'naziv_grupe' then
        UpitOpen( Upit, ' select a.plu, a.ean, a.naziv_artikla, g.naziv_grupe, a.broj, a.rok, a.jm'+
                        ', cijena=a.cijena_art_u_skl, a.sifra_artikla'+
                        ' from '+baza+'.dbo.vaga_artikal a, '+
                            ' '+baza+'.dbo.vaga_grupa g'+
                        ' where a.sifra_grupe=g.sifra_grupe'+
                        ' order by g.naziv_grupe, a.naziv_artikla' )
     else if Sif = 'naziv_artikla' then
        UpitOpen( Upit, ' select a.plu, a.ean, a.naziv_artikla, g.naziv_grupe, a.broj, a.rok, a.jm'+
                        ', cijena=a.cijena_art_u_skl, a.sifra_artikla'+
                        ' from '+baza+'.dbo.vaga_artikal a, '+
                            ' '+baza+'.dbo.vaga_grupa g'+
                        ' where a.sifra_grupe=g.sifra_grupe'+
                        ' and a.naziv_artikla like "'+S+'%"'+
                        ' order by a.'+Sif )
     else //if Sif = 'plu' then
        UpitOpen( Upit, ' select a.plu, a.ean, a.naziv_artikla, g.naziv_grupe, a.broj, a.rok, a.jm'+
                        ', cijena=a.cijena_art_u_skl, a.sifra_artikla'+
                        ' from '+baza+'.dbo.vaga_artikal a, '+
                            ' '+baza+'.dbo.vaga_grupa g'+
                        ' where a.sifra_grupe=g.sifra_grupe'+
                        ' order by a.'+Sif ) ;
     Floatiraj(Upit);
     Upit.Locate( Sif, S, [loPartialKey] );
end;

procedure TData.Action_Insert;
var I: Integer;
    S, Zsql, Isp: String;
begin
     Act := 'New';
     EditForm.Edit1.Clear;
     EditForm.Edit2.Clear;
     EditForm.Combobox1.Clear;
     EditForm.Edit3.Clear;
     EditForm.Edit4.Clear;
     EditForm.Edit6.Clear;
     EditForm.Edit7.Clear;
     UpitOpen( Upit2, 'select plu from '+baza+'.dbo.vaga_artikal where ean="999999" order by plu' );
     if not Upit2.Fields[0].IsNull then EditForm.Edit1.Text := Upit2.Fields[0].AsString
     else begin
          UpitOpen( Upit2, 'select max(plu) from '+baza+'.dbo.vaga_artikal' );
          EditForm.Edit1.Text := IntToStr(Upit2.Fields[0].AsInteger+1);
     end;
     UpitOpen( Upit2, 'select naziv_grupe from '+baza+'.dbo.vaga_grupa' );
     for I := 1 to Upit2.RecordCount do
     begin
          EditForm.Combobox1.Items.Add( Upit2.Fields[0].AsString );
          Upit2.Next;
     end;
     EditForm.ShowModal;
     if EditForm.ModRes then
     begin
          Isp := EditForm.Edit3.Text;
          while Pos('�', Isp) > 0 do Isp[Pos('�', Isp)] := ' ';
          S := Upit.Fields[0].AsString;
          Zsql := Upit.SQL.Text;
          UpitOpen( Upit2, 'select sifra_grupe from '+baza+'.dbo.vaga_grupa where naziv_grupe="'+EditForm.ComboBox1.Text+'"' );
// Edit insert
          Plu := EditForm.Edit1.Text;
          Ean := EditForm.Edit2.Text;
          Art := EditForm.Edit6.Text;
          Naz := EditForm.Edit3.Text;
          Gru := Upit2.Fields[0].AsString;
          Rok := EditForm.Edit5.Text;
          Dat1 := '00';
          Dat2 := '0001';
          Cij := DajCijenu(Art,3);
          if EditForm.ComboBox2.Text='KG' then JM:='0' else JM:='1';
          if JM='1' then Eti:='2' else Eti:='1';
          if Rok <> '' then
          begin
               Dat1 := '03';
               Dat2 := '0041';
          end;
// Dodavanje ili Updejtanje PLUova u bazi
          Prep.Clear;
          UpitOpen( Upit,' select plu from '+baza+'.dbo.vaga_artikal where '+
                         ' plu="'+EditForm.Edit1.Text+'"' );
          if Upit.Fields[0].IsNull then
              Prep.Add( 'insert into '+baza+'.dbo.vaga_artikal '+
                        'values('+Plu+',"'+Ean+'","'+Naz+'","'+
                        Upit2.Fields[0].AsString+'","'+EditForm.Edit4.Text+
                        '","'+Isp+'","'+Rok+'","'+EditForm.ComboBox2.Text+'","'+Art+'"'+
                        ','+Cij+',getdate())' )
          else
              Prep.Add( 'update '+baza+'.dbo.vaga_artikal '+
                        'set ean="'+EditForm.Edit2.Text+
                        '", naziv_artikla="'+Naz+
                        '", sifra_grupe="'+Upit2.Fields[0].AsString+
                        '", broj="'+EditForm.Edit4.Text+
                        '", ispis="'+Isp+
                        '", rok="'+EditForm.Edit5.Text+
                        '", JM="'+EditForm.ComboBox2.Text
                        +'" where plu='+Plu );
          UpitExec( Upit, Prep );
// Generiranje komandi za vage
          for I := 1 to (6-Length(Plu)) do Plu := '0'+Plu;
          for I := 1 to (13-Length(Ean)) do Ean := '0'+Ean;
          for I := 1 to (100-Length(Naz)) do Naz := Naz+' ';
          for I := 1 to (3-Length(Rok)) do Rok := '0'+Rok;
          for I := 1 to (8-Length(Cij)) do Cij := '0'+Cij;
          for I := 1 to (4-Length(Gru)) do Gru := '0'+Gru;
          Upis.Add( '0002070000000100'+Plu+Ean+Naz+Cij+'000000000000000000000000000000000000000000000000000000'+Gru+'00000'+JM+'000000000' );
          Upis.Add( '0002080000000100'+Plu+'0'+Eti+'0001060601010101010100'+Dat1+Dat2+'0000000000000000'+Rok+'00000000000000000000000000000000000000000000000000000000000' );
          UpitOpen( Upit, Zsql );        // ponovi originalni upit prije ove operacije
          Floatiraj(Upit);
          Upit.Locate( 'plu', S, [loPartialKey] );  // i na�i PLU koji je upravo dodan/promjenjen
     end;
end;

procedure TData.Action_Edit;
var I, J: Integer;
    S, Zsql, Isp: String;
begin
     Act := 'Edit';
     EditForm.Edit1.Text := Upit.Fields[0].AsString;
     EditForm.Edit2.Text := Upit.Fields[1].AsString;
     EditForm.Combobox1.Clear;
     UpitOpen( Upit2, ' select naziv_grupe from '+baza+'.dbo.vaga_grupa' );
     for I := 1 to Upit2.RecordCount do
     begin
          if Upit2.Fields[0].AsString = Upit.Fields[3].AsString then J := I-1;
          EditForm.Combobox1.Items.Add( Upit2.Fields[0].AsString );
          Upit2.Next;
     end;
     EditForm.Combobox1.ItemIndex := J;
     EditForm.Edit3.Text := Upit.Fields[2].AsString;
     EditForm.Edit4.Text := Upit.Fields[4].AsString;
     EditForm.Edit5.Text := Upit.Fields[5].AsString;
     EditForm.Edit7.Text := Upit.Fields[7].AsString;       // cijena_art_u_skl
     EditForm.Edit6.Text := Upit.Fields[8].AsString;       // sifra_artikla
     EditForm.ComboBox2.Text := Upit.Fields[6].AsString;
     EditForm.ShowModal;
     if EditForm.ModRes then
     begin
          Isp := EditForm.Edit3.Text;
          while Pos('�', Isp) > 0 do Isp[Pos('�', Isp)] := ' ';
          S := Upit.Fields[0].AsString;
          Zsql := Upit.SQL.Text;
          UpitOpen( Upit2, 'select sifra_grupe from '+baza+'.dbo.vaga_grupa where naziv_grupe="'+EditForm.ComboBox1.Text+'"' );
          Plu := EditForm.Edit1.Text;
          Ean := EditForm.Edit2.Text;
          Art := EditForm.Edit6.Text;
          Naz := EditForm.Edit3.Text;
          Gru := Upit2.Fields[0].AsString;
          Rok := EditForm.Edit5.Text;
          Dat1 := '00';
          Dat2 := '0001';
          Cij := DajCijenu(Art,1);
          if EditForm.ComboBox2.Text='KG' then JM := '0' else JM := '1'; // 1=komadno, 0=koli�inski
          if JM='1' then Eti:='2' else Eti:='1';
          if Rok <> '' then
          begin
               Dat1 := '03';
               Dat2 := '0041';
          end;
          for I := 1 to (6-Length(Plu)) do Plu := '0'+Plu;
          for I := 1 to (13-Length(Ean)) do Ean := '0'+Ean;
          for I := 1 to (100-Length(Naz)) do Naz := Naz+' ';
          for I := 1 to (3-Length(Rok)) do Rok := '0'+Rok;
          for I := 1 to (8-Length(Cij)) do Cij := '0'+Cij;
          Prep.Clear;
          Prep.Add( 'update '+baza+'.dbo.vaga_artikal set '+
                    'ean="'+EditForm.Edit2.Text+'", '+
                    'naziv_artikla="'+Naz+'", '+
                    'sifra_grupe="'+Gru+'", '+
                    'broj="'+EditForm.Edit4.Text+'", '+
                    'ispis="'+Isp+'", '+
                    'rok="'+EditForm.Edit5.Text+'", '+
                    'jm="'+EditForm.ComboBox2.Text+'", '+
                    'sifra_artikla="'+Art+
                    '" where plu='+Plu );
          for I := 1 to (4-Length(Gru)) do Gru := '0'+Gru;
          Upis.Add( '0002070000000100'+Plu+Ean+Naz+Cij+'000000000000000000000000000000000000000000000000000000'+Gru+'00000'+JM+'000000000' );
          Upis.Add( '0002080000000100'+Plu+'0'+Eti+'0001060601010101010100'+Dat1+Dat2+'0000000000000000'+Rok+'00000000000000000000000000000000000000000000000000000000000' );
          UpitExec( Upit, Prep );
          UpitOpen( Upit, Zsql );
          Floatiraj(Upit);
          Upit.Locate( 'plu', S, [loPartialKey] );
     end;
end;

procedure TData.Action_SviPLU;
var I, J: Integer;
    Zsql: String;
begin
     Upit.DisableControls;
     Zsql:=Upit.SQL.Text;
     UpitOpen( Upit, ' select a.plu, a.ean, a.naziv_artikla, a.sifra_grupe,'+
                     ' a.broj, a.rok, a.jm, cijena=a.cijena_art_u_skl'+
                     ' from '+baza+'.dbo.vaga_artikal a'+
                     ' order by a.naziv_artikla' );
     for j:= 0 to Upit.RecordCount -1 do
     begin
          Plu:=Upit.Fields[0].AsString;
          Ean:=Upit.Fields[1].AsString;
          Naz:=Upit.Fields[2].AsString;
          Gru:=Upit.Fields[3].AsString;
          Rok:=Upit.Fields[5].AsString;
          if Upit.Fields[6].AsString='KG' then JM:='0' else JM:='1';
          if JM='1' then Eti:='2' else Eti:='1';
          Cij:=DajCijenu(Upit.Fields[7].AsString,2);
          for I := 1 to (6-Length(Plu)) do Plu := '0'+Plu;
          for I := 1 to (13-Length(Ean)) do Ean := '0'+Ean;
          for I := 1 to (100-Length(Naz)) do Naz := Naz+' ';
          for I := 1 to (3-Length(Rok)) do Rok := '0'+Rok;
          for I := 1 to (8-Length(Cij)) do Cij := '0'+Cij;
          for I := 1 to (4-Length(Gru)) do Gru := '0'+Gru;
          Upis.Add( '0002070000000100'+Plu+Ean+Naz+Cij+'000000000000000000000000000000000000000000000000000000'+Gru+'00000'+JM+'000000000' );
          Upis.Add( '0002080000000100'+Plu+'0'+Eti+'00010606060101010001000000010000000000000000'+Rok+'00000000000000000000000000000000000000000000000000000000000' );
          Upit.Next;
     end;
     UpitOpen( Upit, Zsql );
     Floatiraj(Upit);
     Upit.EnableControls;
     Upit.First;
//     ShowMessage('Upis= '+IntToStr(SizeOf(Upis.Text)));
end;

procedure TData.Action_Delete;
var I: Integer;
    S, Zsql: String;
begin
     if MessageDlg('Odabrali ste brisanje PLU-a.'+#13#10+'  Da li ste sigurni?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
     begin
          S := Upit.Fields[0].AsString;
          Zsql := Upit.SQL.Text;
          Prep.Clear;
          Prep.Add( 'update '+baza+'.dbo.vaga_artikal set ean="999999", sifra_artikla="999999", naziv_artikla="X", sifra_grupe="9999", broj="", ispis="X", rok="" where plu='+Upit.Fields[0].AsString );
          UpitExec( Upit, Prep );
          Plu := S;
          Ean := '999999';
          Art := '999999';
          Naz := 'X';
          Gru := '9999';
          Dat1 := '00';
          Dat2 := '0001';
          Rok := '000';
//          Cij := '00000100';  // Ve� ukodirano u string
          for I := 1 to (6-Length(Plu)) do Plu := '0'+Plu;
          for I := 1 to (13-Length(Ean)) do Ean := '0'+Ean;
          for I := 1 to (100-Length(Naz)) do Naz := Naz+' ';
          Upis.Add( '0002070000000100'+Plu+Ean+Naz+'00000100000000000000000000000000000000000000000000000000000000'+Gru+'000000000000000' );
          Upis.Add( '0002080000000100'+Plu+'020001060601010101010100'+Dat1+Dat2+'0000000000000000'+Rok+'00000000000000000000000000000000000000000000000000000000000' );
          UpitOpen( Upit, Zsql );
          Floatiraj(Upit);
          Upit.Locate( 'plu', S, [loPartialKey] );
     end;
end;

procedure TData.Action_Print;
var I: Integer;
begin
     OdabirForm.ListBox1.Clear;
     OdabirForm.ListBox2.Clear;
     UpitOpen( Upit2, 'select naziv_grupe, sifra_grupe from '+baza+'.dbo.vaga_grupa' );
     for I := 1 to Upit2.RecordCount do
     begin
          OdabirForm.ListBox1.Items.Add( Upit2.Fields[0].AsString );
          OdabirForm.ListBox2.Items.Add( Upit2.Fields[1].AsString );
          Upit2.Next;
     end;
     OdabirForm.ListBox1.Items.Add( '>>> SVE GRUPE <<<' );
     OdabirForm.ListBox2.Items.Add( '>>> SVE GRUPE <<<' );
     OdabirForm.ModRes := False;
     OdabirForm.ShowModal;
     if OdabirForm.ModRes then
     begin
          if OdabirForm.Odabir = '>>> SVE GRUPE <<<' then
             UpitOpen( Upit2, 'select plu, sifra_artikla, ispis, broj, cijena=cijena_art_u_skl from '+baza+'.dbo.vaga_artikal order by ispis' )
          else begin
             UpitOpen( Upit2, 'select plu, sifra_artikla, ispis, broj, cijena=cijena_art_u_skl from '+baza+'.dbo.vaga_artikal where sifra_grupe="'+OdabirForm.Odabir_Sifra+'" order by ispis' );
          end;
          Floatiraj(Upit2);
          IspisForm.QRLabel3.Caption := 'Grupa: '+OdabirForm.Odabir;
          IspisForm.QRLabel14.Caption := 'Grupa: '+OdabirForm.Odabir;
          IspisForm.QuickRep1.Preview;
     end;
end;

procedure TData.Daj_Dodaj_Grupu(S:String);
var I, J: Integer;
    G: String;
begin
     UpitOpen( Upit2, 'select max(sifra_grupe) from '+baza+'.dbo.vaga_grupa where sifra_grupe<>"9999"' );
     if Upit2.Fields[0].IsNull then G := '1'
     else G := IntToStr( Upit2.Fields[0].AsInteger+1 );
     for I := 1 to 4-Length( G ) do G := '0'+G;
     Prep.Clear;
     Prep.Add( 'insert into '+baza+'.dbo.vaga_grupa values("'+G+'","'+S+'")' );
     UpitExec( Upit2, Prep );
     EditForm.Combobox1.Clear;
     UpitOpen( Upit2, 'select naziv_grupe from '+baza+'.dbo.vaga_grupa' );
     for I := 1 to Upit2.RecordCount do
     begin
          if Upit2.Fields[0].AsString = S then J := I-1;
          EditForm.Combobox1.Items.Add( Upit2.Fields[0].AsString );
          Upit2.Next;
     end;
     EditForm.Combobox1.ItemIndex := J;
end;

function TData.DajCijenu(sif:String;opt:Integer):String;
Begin
     if (opt=0) or (opt=1) then
     Begin
          UpitOpen(Cijena, ' select cijena=cijena_art_u_skl from artikal_u_skl '+
                           ' where sifra_org_jedinice="'+skladiste+'"'+
                           ' and sifra_artikla="'+sif+'"');
          Floatiraj(Cijena);
          if Cijena.Fields[0].IsNull then Result:='00000000' else Result:=Cijena.Fields[0].AsString;
          if opt=1 then
          Begin
             if Pos(',',Result)>0 then
                while ((length(Result))-Pos(',',Result))<2 do Result:=Result+'0'
                else Result:=Result+'00';
             //Delete(Result,Pos('.',Result)+3,length(Result)-Pos('.',Result)+3); // Makni vi�ak brojeva iza 2. decimale
             while Pos(',', Result)>0 do Delete(Result,Pos(',',Result),1);      // Obri�i sve ',' iz broja
             while Pos('.', Result)>0 do Delete(Result,Pos('.',Result),1);      // Obri�i sve '.' iz broja
          end;
     end
     else if opt=2 then
     Begin
          Result:=sif;
          if Pos(',',Result)>0 then
             while ((length(Result))-Pos(',',Result))<2 do Result:=Result+'0'
             else Result:=Result+'00';
          //Delete(Result,Pos('.',Result)+3,length(Result)-Pos('.',Result)+3); // Makni vi�ak brojeva iza 2. decimale
          while Pos(',', Result)>0 do Delete(Result,Pos(',',Result),1);      // Obri�i sve ',' iz broja
          while Pos('.', Result)>0 do Delete(Result,Pos('.',Result),1);      // Obri�i sve '.' iz broja
     end
     else if opt=3 then
     Begin
          UpitOpen(Cijena, ' select cijena=cijena_art_u_skl from artikal_u_skl '+
                           ' where sifra_org_jedinice="'+skladiste+'"'+
                           ' and sifra_artikla="'+sif+'"');
          Floatiraj(Cijena);
          if Cijena.Fields[0].IsNull then ShowMessage('Artikal niju u skladi�tu!') else Result:=Cijena.Fields[0].AsString;
          while Pos(',', Result)>0 do Result[Pos(',',Result)]:='.';      // Obri�i sve ',' iz broja
          ShowMessage(Result);
     end
     else ShowMessage('Gre�ka kod konverzije cijene!');
end;

procedure TData.Azuriraj;
var Zsql, vrijeme: String;
begin
     Upit.DisableControls;
     Zsql:=Upit.SQL.Text;
     vrijeme:=DateTimeToStr(IncSecond(Now,-1));
     Prep.Clear;         // Dodaj nove cijene (Konzumove, sa barkodom 28%)
     Prep.Add( ' insert into '+baza+'.dbo.vaga_artikal'+
               ' SELECT'+
               ' plu=substring(b.SIFRA_BAR_KODA,3,4), ean=substring(b.SIFRA_BAR_KODA,3,4),'+
               ' Naziv_artikla=a.skraceni_naziv, sifra_grupe="0009", broj=null, ispis=a.naziv_artikla,'+
               ' rok=null, JM=a.jedinica_mjere, sifra_artikla=a.sifra_artikla, skl.cijena_art_u_skl, datum_promjene=getdate()'+
               ' FROM BAR_KOD b (nolock), artikal a (nolock), artikal_u_skl skl (nolock)'+
               ' WHERE b.SIFRA_BAR_KODA LIKE "28%"'+
               ' and skl.sifra_artikla=b.sifra_artikla and skl.sifra_org_jedinice="'+skladiste+'"'+
               ' and a.sifra_artikla=b.sifra_artikla'+
               ' and a.sifra_artikla not in (select sifra_artikla from '+baza+'.dbo.vaga_artikal)');
     UpitExec(Upit,prep);
     Prep.Clear;         // A�uriranje novih naziva (Konzumove, sa barkodom 28%)
     Prep.Add( ' update '+baza+'.dbo.vaga_artikal'+
               ' set Naziv_artikla=a.skraceni_naziv, ispis=a.naziv_artikla,'+
               ' datum_promjene=getdate()'+
               ' from artikal a (nolock), BAR_KOD b (nolock)'+
               ' where a.sifra_artikla='+baza+'.dbo.vaga_artikal.sifra_artikla'+
               ' and '+baza+'.dbo.vaga_artikal.naziv_artikla<>a.skraceni_naziv'+
               ' and b.SIFRA_BAR_KODA LIKE "28%"'+
               ' and a.sifra_artikla=b.sifra_artikla');
     UpitExec(Upit,prep);
     Prep.Clear;         // A�uriraj nove cijene (svi PLUovi)
     Prep.Add( ' update '+baza+'.dbo.vaga_artikal'+
               ' set cijena_art_u_skl=skl.cijena_art_u_skl,'+
               ' datum_promjene=getdate()'+
               ' from artikal_u_skl skl (nolock)'+
               ' where skl.sifra_artikla='+baza+'.dbo.vaga_artikal.sifra_artikla'+
               ' and '+baza+'.dbo.vaga_artikal.cijena_art_u_skl<>skl.cijena_art_u_skl'+
               ' and skl.sifra_org_jedinice="'+skladiste+'"');
     UpitExec(Upit,prep);
     ShowMessage('Ukupno '+KolikoPromjena(vrijeme)+' promjena od '+vrijeme);
     UpitOpen(Upit, Zsql);
     Floatiraj(Upit);
     Upit.EnableControls;
end;

function TData.KolikoPromjena(dat:String):String;
Begin
     UpitOpen(Upit,' select count(*) from '+baza+'.dbo.vaga_artikal '+
                   ' where datum_promjene>"'+SQLDatum(dat)+'"');
     if Upit.Fields[0].IsNull then Result:='0' else Result:=Upit.Fields[0].AsString;
end;

function TData.SQLDatum(dat:string):string;
var Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
     DecodeDateTime(StrToDateTime(dat), Year, Month, Day, Hour, Min, Sec, MSec);
     Result:=IntToStr(Month)+'.'+IntToStr(Day)+'.'+IntToStr(Year)+' '+IntToStr(Hour)+':'+IntToStr(Min)+':'+IntToStr(Sec);
end;

procedure TData.Daj_Izmjene;
var str,zsql: string;
    i,j: integer;
begin
     Upit.DisableControls;
     zsql:=Upit.SQL.Text;
     With PojamForm do
     begin
          str:=Caption;
          Caption:='Upi�ite od kada �elite izmjene';
          Edit1.Text:=izmjena;
          Edit1.SelectAll;
          ShowModal;
          if ModRes then
          Begin
            UpitOpen(Upit, ' select a.plu, a.ean, a.naziv_artikla, g.naziv_grupe, a.broj,'+
                           ' a.rok, a.jm, cijena=a.cijena_art_u_skl'+
                           ' from '+baza+'.dbo.vaga_artikal a, '+baza+'.dbo.vaga_grupa g'+
                           ' where a.sifra_grupe=g.sifra_grupe'+
                           ' and a.datum_promjene>"'+SQLDatum(Edit1.Text)+'"'+
                           ' order by a.naziv_artikla' );
            Floatiraj(Upit);
            if not Upit.Fields[0].IsNull then
            begin
                 Upit.First;
                 Upis.Clear;
                 For J:=0 to Upit.RecordCount-1 do
                 begin
                      UpitOpen( Upit2, 'select sifra_grupe from '+baza+'.dbo.vaga_grupa where naziv_grupe="'+Upit.Fields[3].AsString+'"' );
                      Plu := Upit.Fields[0].AsString;
                      Ean := Upit.Fields[1].AsString;
                      Naz := Upit.Fields[2].AsString;
                      Gru := Upit2.Fields[0].AsString;
                      Rok := Upit.Fields[5].AsString;
                      Dat1 := '00';
                      Dat2 := '0001';
                      Cij := DajCijenu(Upit.Fields[7].AsString,2);
                      if Upit.Fields[6].AsString='KG' then JM := '0' else JM := '1'; // 1=komadno, 0=koli�inski
                      if JM='1' then Eti:='2' else Eti:='1';
                      if Rok <> '' then begin Dat1 := '03'; Dat2 := '0041'; end;
                      for I := 1 to (6-Length(Plu)) do Plu := '0'+Plu;
                      for I := 1 to (4-Length(Gru)) do Gru := '0'+Gru;
                      for I := 1 to (13-Length(Ean)) do Ean := '0'+Ean;
                      for I := 1 to (100-Length(Naz)) do Naz := Naz+' ';
                      for I := 1 to (3-Length(Rok)) do Rok := '0'+Rok;
                      for I := 1 to (8-Length(Cij)) do Cij := '0'+Cij;
                      Upis.Add( '0002070000000100'+Plu+Ean+Naz+Cij+'000000000000000000000000000000000000000000000000000000'+Gru+'00000'+JM+'000000000' );
                      Upis.Add( '0002080000000100'+Plu+'0'+Eti+'0001060601010101010100'+Dat1+Dat2+'0000000000000000'+Rok+'00000000000000000000000000000000000000000000000000000000000' );
                      Upit.Next;
                 end;
                 izmjena:=DateTimeToStr(Now);
            end else ShowMessage('Nema promjena od '+Edit1.Text);
          end;
          Caption:=str;
     end;
     UpitOpen(Upit, Zsql);
     Floatiraj(Upit);
     Upit.EnableControls;
end;

procedure TData.UpitAfterOpen(DataSet: TDataSet);
begin
     MainForm.StatusBar1.SimpleText:='Ukupno PLU-ova: '+IntToStr(Upit.RecordCount)+', Ukupno za slanje: '+IntToStr(Upis.Count div 2);
end;

procedure TData.SlovaConvert(s:TStringList);
var i,j: integer;
    l: string;
begin
     For i:=0 to s.Count -1 do
     begin
         l:=s[i];
         For j:=0 to length(l)-1 do
         begin
              if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�'
              else if l[j]='�' then l[j]:='�';
         end;
         s[i]:=l;
     end;
end;

end.

