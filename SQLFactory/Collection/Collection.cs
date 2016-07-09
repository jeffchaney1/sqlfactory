using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Collection
{
    public interface IOwnedItem
    {
        IOwnedItem Owner { get; set; }

    }

    public class OwningCollection<TOwnedItem> : IList<TOwnedItem>
        //, ICollection<TOwnedItem>, IList, ICollection
        //            ,IReadOnlyList<TOwnedItem>, IReadOnlyCollection<TOwnedItem>, IEnumerable<TOwnedItem>, IEnumerable
                    ,IOwnedItem

        where TOwnedItem : IOwnedItem
    {
        public IOwnedItem Owner { get; set; }

        List<TOwnedItem> elements = new List<TOwnedItem>();

        public virtual int Add(TOwnedItem value)
        {
            int idx = this.elements.Count();
            this.Insert(idx, value);
            return idx;
        }

        void ICollection<TOwnedItem>.Add(TOwnedItem value)
        {
            this.Add(value); 
        }

        public void Clear()
        {
            elements.Clear();
        }

        public bool Contains(TOwnedItem value)
        {
            return elements.Contains(value);
        }

        public int IndexOf(TOwnedItem value)
        {
            return elements.IndexOf(value);
        }

        public virtual void Insert(int index, TOwnedItem value)
        {
            elements.Insert(index, value);
            value.Owner = this;
        }

        public TOwnedItem First()
        {
            return this.elements.First();
        }

        public IEnumerable<TOwnedItem> Skip(int index) 
        {
            return this.elements.Skip(index);
        }

        public bool IsFixedSize
        {
            get { return false; }
        }

        public bool IsReadOnly
        {
            get { return false; }
        }

        public bool Remove(TOwnedItem value)
        {
            return elements.Remove(value);
        }

        public void RemoveAt(int index)
        {
            elements.RemoveAt(index);
        }

        public TOwnedItem this[int index]
        {
            get
            {
                return elements[index];
            }
            set
            {
                elements[index] = value;
            }
        }

        public void CopyTo(Array array, int index)
        {
            this.elements.CopyTo((TOwnedItem[])array, index);
        }

        public void CopyTo(TOwnedItem[] array, int index)
        {
            this.elements.CopyTo(array, index);
        }

        public int Count
        {
            get { return this.elements.Count(); }
        }

        public bool IsSynchronized
        {
            get { return false; }
        }

        public object SyncRoot
        {
            get { throw new NotImplementedException(); }
        }

        public IEnumerator<TOwnedItem> GetEnumerator()
        {
            return this.elements.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return this.elements.GetEnumerator();
        }


    }
}
