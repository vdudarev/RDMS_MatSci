using InfProject.Models;
using System.Text;

namespace InfProject.Utils
{
    public class RubricsUtils
    {
        /// <summary>
        /// Build Catalog recursively to build the tree
        /// </summary>
        /// <param name="i">current row in a list</param>
        /// <param name="ParentId">parent Id of rubric</param>
        /// <param name="cat">all rubrics</param>
        /// <returns></returns>
        public static string BuildCatalog(ref int i, int ParentId, List<RubricInfo> cat)
        {
            int curParentId, RubricID, LevelNum;
            StringBuilder result = new StringBuilder();
            string strTmp;
            while (i < cat.Count)
            {
                curParentId = cat[i].ParentId;

                if (ParentId != curParentId)
                {
                    break;
                }
                int j = i++;
                LevelNum = cat[j].Level;

                result.Append(string.Format("<li id=\"cat_{0}\"{4}><a href=\"{2}\">{1}</a><span></span>{3}</li>",
                RubricID = cat[j].RubricId,
                cat[j].RubricName,  // LevelNum > 0 ? cat[j]RubricTitleServerFull : cat[j].RubricName,
                GetUrlForRubric(cat[j].TypeId, cat[j].RubricId, cat[j].RubricNameUrl),
                !string.IsNullOrEmpty(strTmp = BuildCatalog(ref i, RubricID, cat)) ? "<ul class=\"child-cat\">" + strTmp + "</ul>" : string.Empty,
                (cat[j].LeafFlag & 4) == 0 ? " data-childs=\"1\"" : string.Empty
                ));

            }
            return result.ToString();
        } // BuildCatalog


        public static string GetUrlForRubric(int TypeId, int RubricId, string RubricNameUrl) {
            // /admintree/manualedit/{TypeId}
            //if (string.IsNullOrEmpty(RubricNameUrl) || string.Compare()) 
            return $"/rubric/{RubricNameUrl}";
        }

    }
}
