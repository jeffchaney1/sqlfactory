{******************************************************************************
  Implementation of a class that will parse a String into a TSQLFactory
  &nbsp;
  At this time only support for SELECT statements is provided.
  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2010/01/29 19:10:56 $
  @group Shared.SQLFactory
  @see CommonStringLib.TTokenizer
  @version $Id: SQLParser.pas,v 1.11 2010/01/29 19:10:56 jchaney Exp $
  @version
******************************************************************************}

unit SQLParser;

interface

uses UnitVersion, SQLFactory, Classes, SysUtils;

{******************************************************************************
  SQL Parser Exceptions
******************************************************************************}
type ESQLParseException = class(Exception);

{******************************************************************************
  Parses a SQL SELECT command string to a TSQLSelectFactory
  @param SQLText The string that holds the SQL Select command
  @param The TSQLSelectFactory that is to be filled by the parser.
  @throws ESQLParserException
******************************************************************************}
procedure ParseSQLSelect(const SQLText : WideString; SQLSelect : TSQLSelectFactory); overload;

{******************************************************************************
  Parses a SQL SELECT command string into a TSQLSelectFactory
  @param SQLText The string that holds the SQL Select command
  @return A TSQLSelectFactory with the parsed SQL Select command
  @throws ESQLParserException
******************************************************************************}
function ParseSQLSelect(const SQLText : WideString) : TSQLSelectFactory; overload;

implementation

uses CommonStringLib, CommonObjLib, Tokenizer;

procedure ParseTopCount(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch('TOP', Tokenizer.CurrentToken.TokenString) then
    Tokenizer.NextToken;
  if (Tokenizer.CurrentToken.TokenType = ttNumeric) then begin
    SQLSelect.TopCount := StrToIntDef(Tokenizer.CurrentToken.TokenString, 0);
    Tokenizer.NextToken;
  end;
end;

function ParseAndAppendUntil(Tokenizer : TTokenizer; UntilTokenTypes : TTokenTypes) : String;
Var
  SaveSkipWhitespace : Boolean;
  tmp : WideString;
begin
  Result := '';
  SaveSkipWhitespace := Tokenizer.SkipWhitespace;
  Tokenizer.SkipWhitespace := False;
  try
    while (Tokenizer.CurrentToken.TokenType <> ttEnd)
      and (not (Tokenizer.CurrentToken.TokenType in UntilTokenTypes)) do
    begin
      if (Tokenizer.CurrentToken.TokenType = ttWhitespace) then
        tmp := ' '
      else
        tmp := Tokenizer.CurrentToken.TokenString;
      Result := Result + tmp;
      Tokenizer.NextToken;
    end;
  finally
    Tokenizer.SkipWhitespace := SaveSkipWhitespace;
  end;
end;

procedure ParseSelectFieldList(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch('*', Tokenizer.CurrentToken.TokenString) then begin
    Tokenizer.NextToken;
    Exit;
  end;
  SQLSelect.Columns.Add(ParseAndAppendUntil(Tokenizer, [ttEnd, ttDelimiter, ttKeyWord]));
  while (not (Tokenizer.CurrentToken.TokenType in [ttEnd, ttKeyword])) do begin
    if (Tokenizer.CurrentToken.TokenType in [ttDelimiter, ttWhitespace]) then
      Tokenizer.NextToken;
    SQLSelect.Columns.Add(ParseAndAppendUntil(Tokenizer, [ttEnd, ttDelimiter, ttKeyWord]));
  end;
end;

procedure ParseSourceTable(Tokenizer : TTokenizer; FromTable : TFromTable);
var
  Schema, Name, Alias : String;
begin
  Schema := '';
  Alias := '';
  Name := Tokenizer.CurrentToken.TokenString;
  while (Tokenizer.NextToken.TokenString = '.') do begin
    Schema := Schema + '.' + Name;
    Name := Tokenizer.NextToken.TokenString;
  end;
  Schema := Copy(Schema, 2, Length(Schema));

  if StringMatch('AS', Tokenizer.CurrentToken.TokenString) then
    Tokenizer.NextToken;

  if (Tokenizer.CurrentToken.TokenType = ttIdentifier) then begin
    Alias := Tokenizer.CurrentToken.TokenString;
    Tokenizer.NextToken;
  end;

  FromTable.TableSchema := Schema;
  FromTable.TableName := Name;
  FromTable.TableAlias := Alias;
end;

    //function ParseConditionGroup(subBuffer : String) : TCondition;
    //Var
    //  subGroup : TConditionGroup;
    //  subTokenizer : TTokenizer;
    //begin
    //  subGroup := TConditionGroup.Create(nil);
    //  subTokenizer : TTokenizer.create(subBuffer);
    //  try try
    //    ParseConditionList(subTokenizer, subGroup.Conditions);
    //
    //    if (subGroup.Conditions.Count > 1) then
    //      Result := subGroup;
    //    else begin
    //      if (subGroup.Conditions.Count = 1) then begin
    //        Result := subGroup.Conditions[0];
    //        Result.Collection := nil;
    //      end;
    //      SafeFree(subGroup);
    //    end;
    //  except
    //    SafeFree(subGroup);
    //    raise;
    //  end;
    //  finally
    //    SafeFree(subTokenizer);
    //  end;
    //end;
    //
    //function ParseConditionSingle(Tokenizer : TTokenizer) : TCondition;
    //Var
    //  IsNegative : Boolean;
    //  OperandA, Operator, OperandB : String;
    //begin
    //  IsNegative := False;
    //  if StringMatch(Tokenizer.CurrentToken.TokenString, 'NOT') then begin
    //    IsNegative := True;
    //    Tokenizer.NextToken;
    //  end;
    //
    //  if (Tokenizer.CurrentToken.TokenType = ttGroup) then begin
    //    Result := ParseConditionGroup(Tokenizer);
    //    Result.IsNegative := IsNegative;
    //    Exit;
    //  end;
    //
    //  OperandA := Tokenizer.CurrentToken.TokenString;
    //  if (IsNegative) then
    //    OperandA := 'NOT ' + OperandA;
    //
    //  Tokenizer.NextToken;
    //
    //  if (Tokenizer.CurrentToken.TokenType = ttGroup) then begin
    //    // Function
    //    OperandA := OperandA + Tokenizer.CurrentToken.TokenString;
    //    Tokenizer.NextToken;
    //  end;
    //
    //  Operator := Tokenizer.CurrentToken.TokenString;
    //  if StringMatch(Operator, 'NOT') then begin
    //    // NOT LIKE  or NOT IN
    //    Operator := Operator + ' ' + Tokenizer.NextToken.TokenString;
    //  end;
    //
    //  Tokenizer.NextToken;
    //  OperandB := Tokenizer.CurrentToken.TokenString;
    //  if StringMatch(OperandB, 'NOT') then begin
    //    OperandB := OperandB + ' ' + Tokenizer.NextToken.TokenString;
    //  end;
    //end;

procedure ParseConditionList(Tokenizer : TTokenizer; ConditionList : TConditionList);
var
  expression : String;
  SaveSkipWhitespace : Boolean;
begin
  expression := '';

  SaveSkipWhitespace := Tokenizer.SkipWhitespace;
  Tokenizer.SkipWhitespace := False;
  try
    while not (Tokenizer.CurrentToken.TokenType in [ttKeyword, ttEnd]) do begin
      expression := expression + Tokenizer.CurrentToken.TokenString;
      Tokenizer.NextToken;
    end;
  finally
    Tokenizer.SkipWhitespace := SaveSkipWhitespace;
  end;
  If (Trim(expression) <> '') then
    ConditionList.Add(Trim(expression));
end;

procedure ParseFrom(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch('FROM', Tokenizer.CurrentToken.TokenString) then
    Tokenizer.NextToken;

  ParseSourceTable(Tokenizer, SQLSelect.FromTable);
end;


procedure ParseJoinTo(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
var
  JoinTable : TJoinTable;
begin
  JoinTable := TJoinTable(SQLSelect.JoinTo.Add);
  if StringMatch('LEFT', Tokenizer.CurrentToken.TokenString) then
    JoinTable.JoinType := jtLeftJoin
  else if StringMatch('RIGHT', Tokenizer.CurrentToken.TokenString) then
    JoinTable.JoinType := jtRightJoin
  else if StringMatch('FULL', Tokenizer.CurrentToken.TokenString) then
    JoinTable.JoinType := jtFullJoin;
  // else
  //  JoinType := jtJoin;

  Tokenizer.NextToken;
  if (StringMatch(Tokenizer.CurrentToken.TokenString, 'OUTER')) then
    Tokenizer.NextToken;

  if (StringMatch(Tokenizer.CurrentToken.TokenString, 'JOIN')) then
    Tokenizer.NextToken;

  ParseSourceTable(Tokenizer, JoinTable);

  if (StringMatch(Tokenizer.CurrentToken.TokenString, 'ON')) then
    Tokenizer.NextToken;

  ParseConditionList(Tokenizer, JoinTable.JoinOn);
end;

procedure ParseGroupBy(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'GROUP') then
    Tokenizer.NextToken;
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'BY') then
    Tokenizer.NextToken;

  while (not (Tokenizer.CurrentToken.TokenType in [ttEnd, ttKeyword])) do begin
    if (Tokenizer.CurrentToken.TokenType = ttDelimiter) then
      Tokenizer.NextToken;
    SQLSelect.GroupBy.Add(ParseAndAppendUntil(Tokenizer, [ttEnd, ttDelimiter, ttKeyWord]));
  end;
end;

procedure ParseWhere(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'WHERE') then
    Tokenizer.NextToken;

  ParseConditionList(Tokenizer, SQLSelect.Where);
end;

procedure ParseOrderBy(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'ORDER') then
    Tokenizer.NextToken;
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'BY') then
    Tokenizer.NextToken;

  while (not (Tokenizer.CurrentToken.TokenType in [ttEnd, ttKeyword])) do begin
    if (Tokenizer.CurrentToken.TokenType = ttDelimiter) then
      Tokenizer.NextToken;
    SQLSelect.OrderBy.Add(ParseAndAppendUntil(Tokenizer, [ttEnd, ttDelimiter, ttKeyWord]));
  end;
end;

procedure ParseHaving(Tokenizer : TTokenizer; SQLSelect : TSQLSelectFactory);
begin
  if StringMatch(Tokenizer.CurrentToken.TokenString, 'HAVING') then
    Tokenizer.NextToken;

  ParseConditionList(Tokenizer, SQLSelect.Having);
end;

function ParseSQLSelect(const SQLText : WideString) : TSQLSelectFactory;
begin
  Result := TSQLSelectFactory.Create;
  try
    ParseSQLSelect(SQLText, Result);
  except
    SafeFreeAndNil(Result);
    raise;
  end;
end;

procedure ParseSQLSelect(const SQLText : WideString; SQLSelect : TSQLSelectFactory);
Var
  Tokenizer : TTokenizer;
begin
  Tokenizer := TTokenizer.Create(SQLText);
  try
    Tokenizer.SkipWhitespace := True;
    Tokenizer.AddGroup('[', ']', ttIdentifier);
    Tokenizer.AddGroup('(', ')', ttGroup, True);
    // Used to stop conditions
    Tokenizer.AddKeywords(['FROM', 'WHERE', 'GROUP', 'ORDER', 'HAVING',
                           'JOIN', 'LEFT', 'RIGHT', 'FULL', 'ON']);

    if (not StringMatch('SELECT', Tokenizer.NextToken.TokenString)) then
      Exit;

    if (StringMatch('TOP', Tokenizer.NextToken.TokenString)) then
      ParseTopCount(Tokenizer, SQLSelect);

    ParseSelectFieldList(Tokenizer, SQLSelect);

    while (Tokenizer.CurrentToken.TokenType <> ttEnd) do begin
      if StringMatch('FROM', Tokenizer.CurrentToken.TokenString) then
        ParseFrom(Tokenizer, SQLSelect)
      else if (   StringMatch('JOIN', Tokenizer.CurrentToken.TokenString)
               or StringMatch('LEFT', Tokenizer.CurrentToken.TokenString)
               or StringMatch('RIGHT', Tokenizer.CurrentToken.TokenString)
               or StringMatch('FULL', Tokenizer.CurrentToken.TokenString) ) then
      begin
        ParseJoinTo(Tokenizer, SQLSelect);
      end
      else if StringMatch('GROUP', Tokenizer.CurrentToken.TokenString) then
        ParseGroupBy(Tokenizer, SQLSelect)
      else if StringMatch('WHERE', Tokenizer.CurrentToken.TokenString) then
        ParseWhere(Tokenizer, SQLSelect)
      else if StringMatch('ORDER', Tokenizer.CurrentToken.TokenString) then
        ParseOrderBy(Tokenizer, SQLSelect)
      else if StringMatch('HAVING', Tokenizer.CurrentToken.TokenString) then
        ParseHaving(Tokenizer, SQLSelect)
      else
        Tokenizer.NextToken;
    end;
  finally
    SafeFree(Tokenizer);
  end;
end;



initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLParser.pas,v $', '$Revision: 1.11 $', '$Date: 2010/01/29 19:10:56 $');
{$ENDIF}
end.

