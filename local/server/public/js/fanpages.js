
document.addEventListener("LoadFanpage", function(event){

      var catId = event.detail;
      
      var selectedItem = [];   
      var selected = -1; 

      var queryCategory = new Parse.Query("Categories");             
      queryCategory.equalTo("objectId", catId);
      queryCategory.first({
          success: function (category) {
              
              if (category) {
                    searchFanpage(category)            
              }
          }
      });
      
      function searchFanpage(category)
      {
            var queryFanpage = new Parse.Query("Fanpage");             
            queryFanpage.equalTo("category", category);
            queryFanpage.find({
                success: function (fanpages) {

                    if (fanpages) {                

                      var clength = fanpages.length;
                      var dataJson = [];

                      for (var i = 0; i < clength; ++i) 
                      {
                          item = {};
                          item["id"] = i+1;
                          var objectId = fanpages[i].id;
                          dataJson.objectId = objectId;
                          item["objectId"] = objectId;                  
                          
                          if (fanpages[i].get("pageIcon") != undefined){                
                            var icon = fanpages[i].get("pageIcon");
                            item["icon"] = icon;
                          } else {
                            item["icon"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                          }

                          
                          var name = fanpages[i].get("pageName");
                          item["name"] = name;
                          var about = fanpages[i].get("pageAbout");
                          item["about"] = about;
                          if (fanpages[i].get("pageCover") != undefined){
                            var cover = fanpages[i].get("pageCover");
                            item["cover"] = cover;
                          } else {
                            item["cover"] = "https://dummyimage.com/150x60/286090/ffffff.png&text=Not+Available";
                          }
                          dataJson.push(item);
                      }                          

                      var rowIds = [];
                      var grid = $("#gridFanpage").bootgrid({                  
                          templates: {
                              header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><button  type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Fanpage </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
                          }, 
                          caseSensitive: true,
                          selection: true,
                          multiSelect: true,                  
                          formatters: {              
                            "icon": function (column, row) {
                                return "<img src=\"" + row.icon + "\" height=\"30\" width=\"30\"/>";
                            },
                            "cover": function (column, row) {
                                return "<img src=\"" + row.cover + "\" height=\"30\" width=\"150\"/>";
                            },
                            "commands": function(column, row) {
                                return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                       "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;";
                                       
                            }                   
                          }               

                      }).on("selected.rs.jquery.bootgrid", function(e, rows) {

                          if ( selectedItem.length > 0) {                       
                               $("#gridFanpage").bootgrid("deselect", [parseInt(selected)]);                                              
                           }

                          var countSelected=0;
                          var rowIds = [];
                          var fanpageId;
                          for (var i = 0; i < rows.length; i++)
                          {                      
                              rowIds.push(rows[i].id); 
                              fanpageId = rows[i].objectId;                               
                          }              

                          selected = rowIds.join(",");
                          selectedItem.push(selected);   
                                     
                          var event = new CustomEvent("LoadVideo", { detail: fanpageId });
                          document.dispatchEvent(event);
                          
                          //alert("Select: " + rowIds.join(","));

                      }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                      {
                          var rowIds = [];
                          for (var i = 0; i < rows.length; i++)
                          {
                              rowIds.push(rows[i].id);
                          }

                      }).on("loaded.rs.jquery.bootgrid", function() {                    

                          grid.find(".command-edit").on("click", function(e) {

                              //alert("You pressed edit on row: " + $(this).data("row-id"));
                              var ele =$(this).parent();
                              var g_id = $(this).parent().siblings(':first').html();
                              var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                              console.log(g_id);
                              console.log(g_name);

                              //console.log(grid.data());//
                              $('#edit_model_fanpage').modal('show');

                              if ($(this).data("row-id") >0) {

                                var f = ele.siblings(':first').html();                        
                                var a1 = ele.siblings(':nth-of-type(1)').html();
                                var a2 = ele.siblings(':nth-of-type(2)').html();
                                var a3 = ele.siblings(':nth-of-type(3)');
                                var a4 = ele.siblings(':nth-of-type(4)').html();
                                var a5 = ele.siblings(':nth-of-type(5)').html();
                                var a6 = ele.siblings(':nth-of-type(6)').html();
                                var a7 = ele.siblings(':nth-of-type(7)').html();

                                // collect the data
                                //$('#edit_id').val(ele.siblings(':first').html());                                                
                                $("#edit_icon").append(a4);
                                $('#edit_name').val(a5);
                                $('#edit_about').val(a6);
                                $('#edit_cover').append(a7);                       

                              } else {
                                 alert('Now row selected! First select row, then click edit button');
                              }

                          }).end().find(".command-delete").on("click", function(e) {
                                

                          }).end().find(".command-fanpage").on("click", function(e) {
                              

                          });
                      });

                      grid.bootgrid("append", dataJson);

                    } else {
                        console.log("Nothing found, please try again");
                    }

                },
                error: function (error) {
                    console.log("Error: " + error.code + " " + error.message);
                }
            });

              $( "#btn_thumb_image" ).click(function() {
                  alert("");
              });

              $( "#btn_back_image" ).click(function() {
                alert("");
              });

              $( "#btn_edit" ).click(function() {

                //CLEAN UP FORM IMAGES AND ALL DATA
                //alert("");
              });

              function removeAssetsFromPopup(){}    
      }  

});