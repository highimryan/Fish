//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace FishSurvey
{
    using System;
    using System.Collections.Generic;
    
    public partial class Species
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Species()
        {
            this.Fishes = new HashSet<Fish>();
        }
    
        public int SpeciesId { get; set; }
        public int FamilyId { get; set; }
        public int TrophicId { get; set; }
        public string CommonName { get; set; }
        public string ScientificName { get; set; }
    
        public virtual Family Family { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Fish> Fishes { get; set; }
        public virtual Trophic Trophic { get; set; }
    }
}
