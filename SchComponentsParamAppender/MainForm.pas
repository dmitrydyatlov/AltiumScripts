var
   pathFile : string;
   loadedFile : string;

procedure ShowComponentParametersToAdd(componentClasses : TStringList; componentParametersLists : TList);
var
   i      : integer;
   j      : integer;
   k      : integer;
begin
     k := 1;
     for i := 0 to componentClasses.Count - 1 do
     begin
          Form4.StringGrid1.Cells[0, k] := ComponentClasses[i];
          Form4.StringGrid1.Cells[1, k] := '';
          Form4.StringGrid1.Cells[2, k] := '';
          inc(k);
          Form4.StringGrid1.RowCount := k;
          for j := 0 to componentParametersLists[i].Count - 1 do
          begin
               Form4.StringGrid1.Cells[0, k] := '';
               Form4.StringGrid1.Cells[1, k] := componentParametersLists[i].Names[j];
               Form4.StringGrid1.Cells[2, k] := componentParametersLists[i].ValueFromIndex(j);
               inc(k);
               Form4.StringGrid1.RowCount := k;
          end;
     end;
end;

procedure TForm4.ButtonOpenIniClick(Sender: TObject);
var
   F: text;
   s: string;
begin
     if (OpenIniDialog.Execute) then
     begin
          loadComponentsParametersIni(OpenIniDialog.FileName);
          AssignFile(F, pathfile);
          ReWrite(F);
          WriteLn(F, OpenIniDialog.FileName);
          loadedFile := OpenIniDialog.FileName;
          CloseFile(F);
     end;
end;

procedure TForm4.Form4Create(Sender: TObject);
var
   F: text;
   s: string;
begin
     pathFile := SpecialFolder_AltiumApplicationData + '/' + 'paramAppenderLastIniFilePath.txt';
     loadedFile := '';
     StringGrid1.Cells[0, 0] := 'Component Type';
     StringGrid1.Cells[1, 0] := 'Parameter Name';
     StringGrid1.Cells[2, 0] := 'Parameter Default Value';
     if (fileExists(pathFile)) then
     begin
          AssignFile(F, pathfile);
          Reset(F);
          ReadLn(F, s);
          CloseFile(F);
          if (FileExists(s)) then
          begin
             loadComponentsParametersIni(s);
             loadedFile := s;
          end;
     end;
end;


procedure TForm4.Button1Click(Sender: TObject);
var
   processSelectedCmponentsOnly : boolean;
begin
  if (RadioButtonSelectedComponents.Checked xor RadioButtonAllComponents.Checked) = false then
  begin
    ShowMessage('Please, select the option whether to process all components or selected only.');
  end
     else
  begin
   processSelectedCmponentsOnly := RadioButtonSelectedComponents.Checked;
   AddParameters(processSelectedCmponentsOnly);
   ShowMessage('Completed!');
  end;

end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  AddParametersToLibrary;
end;

procedure TForm4.Button3Click(Sender: TObject);
begin
     if (loadedFile <> '') then
     begin
          RunApplication('notepad ' +  loadedFile);
     end
        else
     begin
          ShowMessage('INI file not selected');
     end;
end;


procedure TForm4.Button4Click(Sender: TObject);
begin
  if ((loadedFile <> '') and (FileExists(loadedFile))) then
  begin
    loadComponentsParametersIni(loadedFile);
  end;
end;


