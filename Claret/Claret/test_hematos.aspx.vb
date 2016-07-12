Imports H2GEngine
Public Class test_hematos
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Dim baseH As New oraDBQuery(oraDBQuery.Schema.HEMATOS)

        Dim dt As DataTable = baseH.QueryTable("select pexamen.pex_lib show_exam,
decode(substr(dossex.dex_res,1,1),'*',
presultat.pres_aff||replace(substr(dossex.dex_res,instr(dossex.dex_res,chr(27))),
chr(27)||substr(presultat.pres_aff,instr(presultat.pres_aff,'*'),
(length(presultat.pres_aff)-instr(presultat.pres_aff,':')+2)),'/'),presultat.pres_aff) show_result,
to_char(dossex.dex_dtpdet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_firstdate,
to_char(dossex.dex_dtddet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_lastdate,
dossex.dex_nbdet show_totaltest,
dossex.dex_numpdet show_firstsample,dossex.dex_numddet show_lastsample,
decode(plabo_first.plabo_lib,null,'',dossex.dex_labpdet||'-'||plabo_first.plabo_lib) show_firstlabolatory,
decode(plabo_last.plabo_lib,null,'',dossex.dex_labddet||'-'||plabo_last.plabo_lib) show_lastlabolatory,
pexamen.pex_unitres show_unit
from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
inner join presultat on  trim(presultat.pfres_cd) = trim(pexamen.pex_famres)
and nvl(trim(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)),trim(dossex.dex_res)) = trim(presultat.pres_cd)
left join plabo plabo_first  on dossex.dex_labpdet = plabo_first.plabo_cd
left join plabo plabo_last on dossex.dex_labddet = plabo_last.plabo_cd
where dossex.donn_numero = '1004230339'
order by dex_exam")

        Response.Write(dt.ToString)




    End Sub

End Class