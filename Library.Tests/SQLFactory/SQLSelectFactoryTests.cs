using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Library.SQLFactory;

namespace Library.Tests.SQLFactory
{
    [TestClass]
    public class SQLSelectFactoryTests
    {
        //static String STD_INDENT = Library.SQLFactory.SQLFactory.STD_INDENT;

        [TestMethod]
        public void TestColumnInfo()
        {
            String columnInfo = "[table].[column] alias";
            String tableAlias;
            String columnExpression;
            String columnAlias;

            Library.SQLFactory.SQLFactory.ParseColumnInfo(columnInfo, out tableAlias, out columnExpression, out columnAlias);

            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("[column]", columnExpression);
            Assert.AreEqual("[table]", tableAlias);

        }

        //public static String PrintableCharacters = "[\\040-\\177]";
        //public static String NonPrintableCharacters = PrintableCharacters.Insert(1, "^");
        //public static String IdentifierBodyCharacters = "[0-9A-Za-z_]";
        //public static String NotIdentifierBodyCharacters = IdentifierBodyCharacters.Insert(1, "^");

        //public static void ParseColumnInfo(String columnInfo, out String tableAlias, out String columnExpression, out String columnAlias)
        //{
        //    tableAlias = "";
        //    columnExpression = "";
        //    columnAlias = "";

        //    String cleaned = Regex.Replace(columnInfo, "[^\\040-\\177]", "");
        //    int p=columnInfo.Length;
        //    columnAlias = ParsePrev(ref p, cleaned, " ", "\"", "[]");
        //    if (p > 0) {
        //        columnAlias = RemoveBrackets("[", columnAlias, "]");

        //        if (columnAlias == columnAlias.Replace(NotIdentifierBodyCharacters, "")) {
        //            cleaned = cleaned.Substring(0, p+1);
        //            String tmp = ParsePrev(ref p, cleaned, " ", "\"", "");
        //            if (tmp.Equals("AS", StringComparison.OrdinalIgnoreCase)) 
        //                cleaned = cleaned.Substring(1, p);
        //        }
        //        else {
        //          columnAlias = "";
        //        }
        //    }
        //    else /*there was no alias delimited by a space*/ {
        //        columnAlias = "";
        //    }

        //    p = 0;
        //    columnExpression = ParseNext(ref p, cleaned, ".", "\"'", "[]()");
        //    tableAlias = "";
        //    while (p < cleaned.Length) {
        //        tableAlias = tableAlias + columnExpression;
        //        columnExpression = ParseNext(ref p, cleaned, ".", "\"'", "[]()");
        //    }
        //}

        [TestMethod]
        public void TestSQLSelectFactoryFromTable()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "USERS";
            Assert.AreEqual("SELECT * FROM [USERS]", SELECT.BuildSQL());

            SELECT.FromTable.TableAlias = "ALIAS";
            Assert.AreEqual("SELECT * FROM [USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.TableSchema = "dbo";
            Assert.AreEqual("SELECT * FROM [dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.DatabaseName = "database";
            Assert.AreEqual("SELECT * FROM [database].[dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.ServerName = "Server";
            Assert.AreEqual("SELECT * FROM [Server].[database].[dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.AddDelimiters = false;
            Assert.AreEqual("SELECT * FROM Server.database.dbo.USERS ALIAS", SELECT.BuildSQL());

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "dbo.USERS";
            Assert.AreEqual("USERS", SELECT.FromTable.TableName);
            Assert.AreEqual("USERS", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("", SELECT.FromTable.ServerName);

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "dbo.[USERS] alias";
            Assert.AreEqual("[USERS]", SELECT.FromTable.TableName);
            Assert.AreEqual("alias", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("", SELECT.FromTable.ServerName);

            Assert.AreEqual(false, SELECT.FromTable.AddDelimiters);
            Assert.AreEqual("SELECT * FROM dbo.[USERS] alias", SELECT.BuildSQL());

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "server.Database.dbo.USERS alias";
            Assert.AreEqual("USERS", SELECT.FromTable.TableName);
            Assert.AreEqual("alias", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("Database", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("server", SELECT.FromTable.ServerName);

        }

        [TestMethod]
        public void TestColumns()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SelectColumn col = SELECT.Columns.Add1("COL1");
            Assert.AreEqual("COL1", col.ColumnName);
            Assert.AreEqual("COL1", col.ColumnAlias);
            Assert.AreEqual("SELECT [COL1] \nFROM [table]", SELECT.BuildSQL());

            col = SELECT.Columns.Add1("COL2 COL2_ALIAS");
            Assert.AreEqual("COL2", col.ColumnName);
            Assert.AreEqual("COL2_ALIAS", col.ColumnAlias);
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS] \nFROM [table]", SELECT.BuildSQL());

            col = SELECT.Columns.Add1("table.COL3 COL3_ALIAS");
            Assert.AreEqual("COL3", col.ColumnName);
            Assert.AreEqual("COL3_ALIAS", col.ColumnAlias);
            Assert.AreEqual("table", col.TableName);
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], [table].[COL3] [COL3_ALIAS] \nFROM [table]", SELECT.BuildSQL());

            col.AddDelimiters = false;
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], table.COL3 COL3_ALIAS \nFROM [table]", SELECT.BuildSQL());

            SELECT.Columns.Add(new String[] { "COL4", "COL5 COL5_ALIAS", "table.COL6 COL6_ALIAS" });
            AssertSQL.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], table.COL3 COL3_ALIAS, [COL4], " +
                            "[COL5] [COL5_ALIAS], [table].[COL6] [COL6_ALIAS] " +
                            "FROM [table]"
                            , SELECT.BuildSQL());


        }

        [TestMethod]
        public void TestTopCount()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.TopCount = 100;

            AssertSQL.AreEqual("SELECT TOP 100 * FROM [table]", SELECT.BuildSQL());

            SELECT.Columns.Add(new string[] { "COL1", "COL2" });
            AssertSQL.AreEqual("SELECT TOP 100 [COL1], [COL2] FROM [table]", SELECT.BuildSQL());
        }

        [TestMethod]
        public void TestDistinct()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.Distinct = true;

            AssertSQL.AreEqual("SELECT DISTINCT * FROM [table]", SELECT.BuildSQL());

            SELECT.Columns.Add(new string[] { "COL1", "COL2" });
            AssertSQL.AreEqual("SELECT DISTINCT [COL1], [COL2] FROM [table]", SELECT.BuildSQL());

        }

        [TestMethod]
        public void TestWhere()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.Where.Add("COL1 = 50");

            AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50)", SELECT.BuildSQL());

            SELECT.Where.Add("COL2 < 0");

            AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50) AND (COL2 < 0)", SELECT.BuildSQL());

            SELECT.Where.AddGroup(ConditionLinkOperator.loOR)
                .Conditions.Add(new string[] { "COL3 > 10", "COL4 < COL5" });
            AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50) AND (COL2 < 0) AND ((COL3 > 10) OR (COL4 < COL5))", SELECT.BuildSQL());

            SELECT.Where.Clear();
            SELECT.Where.AddInList("COL1", new String[] { "VALUE1", "VALUE2", "VALUE3" });

            AssertSQL.AreEqual("SELECT * FROM [table] WHERE ([COL1] in ('VALUE1', 'VALUE2', 'VALUE3') )", SELECT.BuildSQL());

            var subSelect = SELECT.Where.AddInSelect("COL2").SubSelect;
            subSelect.FromTable.TableName = "table2";
            subSelect.Columns.Add1("RID");
            subSelect.Where.Add("COL3 > 20");
            AssertSQL.AreEqual("SELECT * FROM [table] " + 
                               " WHERE ([COL1] in ('VALUE1', 'VALUE2', 'VALUE3') )" + 
                               "  AND ([COL2] in (SELECT [RID] FROM [table2] WHERE (COL3 > 20) )"
                               , SELECT.BuildSQL());

        }

        [TestMethod]
        public void TestAdditionalConditions()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.AdditionalConditions.Add("COL1 = 50");

            AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50)", SELECT.BuildSQL());

            SELECT.AdditionalConditions.Add("COL2 < 0");

            AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50) AND (COL2 < 0)", SELECT.BuildSQL());

            SELECT.AdditionalConditions.AddGroup(ConditionLinkOperator.loOR)
                .Conditions.Add(new string[] { "COL3 > 10", "COL4 < COL5" });
            AssertSQL.AreEqual("SELECT * FROM [table] " + 
                               " WHERE (COL1 = 50) AND (COL2 < 0) " + 
                               "   AND ((COL3 > 10) OR (COL4 < COL5))"
                               , SELECT.BuildSQL());

            SELECT.Where.Add("COL0 IS NOT NULL");
            AssertSQL.AreEqual("SELECT * FROM [table] " +
                               " WHERE (COL0 IS NOT NULL) AND (COL1 = 50) " +
                               "  AND (COL2 < 0) AND ((COL3 > 10) OR (COL4 < COL5))"
                              , SELECT.BuildSQL());

        }

        [TestMethod]
        public void TestHaving()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.Having.Add("COL1 = 50");

            AssertSQL.AreEqual("SELECT * FROM [table] HAVING (COL1 = 50)", SELECT.BuildSQL());

            SELECT.Having.Add("COL2 < 0");

            AssertSQL.AreEqual("SELECT * FROM [table] HAVING (COL1 = 50) AND (COL2 < 0)", SELECT.BuildSQL());

            //SELECT.Where.AddGroup(ConditionLinkOperator.loOR)
            //    .Conditions.Add(new string[] { "COL3 > 10", "COL4 < COL5" });
            //AssertSQL.AreEqual("SELECT * FROM [table] WHERE (COL1 = 50) AND (COL2 < 0) AND ((COL3 > 10) OR (COL4 < COL5))", SELECT.BuildSQL());

        }

        [TestMethod]
        public void TestGroupBy()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.Columns.Add(new string[] { "COL1", "COL2", "SUM(COL3)" });

            SELECT.GroupBy.Add("COL1");
            SELECT.GroupBy.Add(SELECT.Columns.Column("COL2"));

            AssertSQL.AreEqual("SELECT [COL1], [COL2], SUM(COL3) " + 
                               "  FROM [table] " + 
                               " GROUP BY [COL1], [COL2]", SELECT.BuildSQL());

        }

        [TestMethod]
        public void TestOrderBy()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SELECT.Columns.Add(new string[] { "COL1", "COL2", "COL3" });

            SELECT.OrderBy.Add("COL1");
            SELECT.OrderBy.Add(SELECT.Columns.Column("COL2")).IsDescending = true; 

            AssertSQL.AreEqual("SELECT [COL1], [COL2], [COL3] " +
                               "  FROM [table] " +
                               " ORDER BY [COL1], [COL2] DESC", SELECT.BuildSQL());

        }

     }
}