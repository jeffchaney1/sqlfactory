using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Library.Collection;

namespace Library.Tests.Collection
{
    [TestClass]
    public class CollectionTests
    {
        class TestItem : IOwnedItem
        {
            public IOwnedItem Owner { get; set; }
        }

        class TestCollection : OwningCollection<TestItem>
        {

        }

        [TestMethod]
        public void TestAdd()
        {
            TestCollection testCollection = new TestCollection();


        }
    }
}
