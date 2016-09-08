using Library.SQLFactory;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests.SQLFactory
{
    [TestClass]
    class SQLDeleteFactoryTests
    {
        [TestMethod]
        public void TestSQLDeleteFactory()
        {
            SQLDeleteFactory DELETE = new SQLDeleteFactory();
            DELETE.FromTable.TableName = "USERS";
            DELETE.AllowNoConditions = true;
            Assert.AreEqual("DELETE [USERS]", DELETE.BuildSQL());

            DELETE.FromTable.TableAlias = "ALIAS";
            Assert.AreEqual("DELETE [USERS] [ALIAS]", DELETE.BuildSQL());

            DELETE.FromTable.TableSchema = "dbo";
            Assert.AreEqual("DELETE [dbo].[USERS] [ALIAS]", DELETE.BuildSQL());

            DELETE.FromTable.DatabaseName = "database";
            Assert.AreEqual("DELETE [database].[dbo].[USERS] [ALIAS]", DELETE.BuildSQL());

            DELETE.FromTable.ServerName = "Server";
            Assert.AreEqual("DELETE [Server].[database].[dbo].[USERS] [ALIAS]", DELETE.BuildSQL());

            DELETE.FromTable.AddDelimiters = false;
            Assert.AreEqual("DELETE Server.database.dbo.USERS ALIAS", DELETE.BuildSQL());

            DELETE = new SQLDeleteFactory();
            DELETE.FromTable.TableName = "dbo.USERS";
            Assert.AreEqual("USERS", DELETE.FromTable.TableName);
            Assert.AreEqual("USERS", DELETE.FromTable.TableAlias);
            Assert.AreEqual("dbo", DELETE.FromTable.TableSchema);
            Assert.AreEqual("", DELETE.FromTable.DatabaseName);
            Assert.AreEqual("", DELETE.FromTable.ServerName);

            DELETE = new SQLDeleteFactory();
            DELETE.FromTable.TableName = "dbo.[USERS] alias";
            Assert.AreEqual("[USERS]", DELETE.FromTable.TableName);
            Assert.AreEqual("alias", DELETE.FromTable.TableAlias);
            Assert.AreEqual("dbo", DELETE.FromTable.TableSchema);
            Assert.AreEqual("", DELETE.FromTable.DatabaseName);
            Assert.AreEqual("", DELETE.FromTable.ServerName);

            DELETE.AllowNoConditions = true;
            Assert.AreEqual(false, DELETE.FromTable.AddDelimiters);
            Assert.AreEqual("DELETE dbo.[USERS] alias", DELETE.BuildSQL());

            DELETE = new SQLDeleteFactory();
            DELETE.FromTable.TableName = "server.Database.dbo.USERS alias";
            Assert.AreEqual("USERS", DELETE.FromTable.TableName);
            Assert.AreEqual("alias", DELETE.FromTable.TableAlias);
            Assert.AreEqual("dbo", DELETE.FromTable.TableSchema);
            Assert.AreEqual("Database", DELETE.FromTable.DatabaseName);
            Assert.AreEqual("server", DELETE.FromTable.ServerName);

        }

        [TestMethod]
        public void TestSQLDeleteConditions()
        {
            SQLDeleteFactory DELETE = new SQLDeleteFactory();
            DELETE.FromTable.TableName = "users";
            DELETE.Where.Add("NAME LIKE :").AddStringParameter("samuel%");

            StringBuilder sql = new StringBuilder();
            ParameterList parameters = new ParameterList();

            DELETE.BuildSQL(sql, parameters);
            AssertSQL.AreEqual("DELETE users WHERE NAME LIKE :", sql.ToString());
            Assert.AreEqual(1, parameters.Count());

        }
    }
}
