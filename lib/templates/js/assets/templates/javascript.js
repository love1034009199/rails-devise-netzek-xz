// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
jQuery ->
  $('#datatable_id').dataTable
    bJQueryUI: true
    bScrollCollapse: true
    bPaginate: true
    bLengthChange: true
    bFilter: true
    bSort: true
    bInfo: true
    bAutoWidth: false
    bStateSave: true
    sPaginationType: "full_numbers"
    oLanguage:{
      sLengthMenu: "每页显示 _MENU_ 条记录"
      sZeroRecords: "对不起，查询不到任何相关数据"
      sInfo: "当前显示 _START_ 到 _END_ 条，共 _TOTAL_ 条记录"
      sInfoEmtpy: "找不到相关数据"
      sInfoFiltered: "数据表中共为 _MAX_ 条记录)"
      sProcessing: "正在加载中..."
      sSearch: "搜索"
      oPaginate: {
        sFirst: "第一页",
        sPrevious: " 上一页 ",
        sNext: " 下一页 ",
        sLast: " 最后一页 "
      }
    }
    aLengthMenu: [[5, 10, 15, -1, 0], [5, 10, 15, "显示所有数据", "不显示数据"]]
    iDisplayLength: 5