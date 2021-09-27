<div id="edit_operation_skill_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign">&nbsp;<span id="edit_branch_modal_title">スキル条件追加</span></span>
					<button type="button" class="btn btn-default pull-right" data-dismiss="modal">閉じる</button>
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <div class="container-fluid">
                        {% if data['skill.enumSkills'] %}
                            {% for itemC in data['skill.enumSkillCategories'] %}
                                <div id="operation_skill_categories_header_{{ loop.index }}" style="border-bottom: 1px solid #e5e5e5; margin-bottom: 10px;margin-top: 10px"><label>{{ itemC }}</label></div>
                                <table class="">
                                 {% for item in data['skill.enumSkills'] %}
                                     {% if itemC == item.category_name %}
                                     <tr>
                                         <td>
                                             <input type="checkbox" name="m_operation_skill[]" id="operation_skill_label_{{ item.id }}" class="search-chk" onchange="viewSelectedOperationSkill();" value="{{ item.id }}">
                                             <label id="skill_{{ item.id }}" for="operation_skill_label_{{ item.id }}" style="font-weight: normal; margin: 0px">{{ item.name }}</label>
                                         </td>
                                         <td>
                                             <select id="m_operation_skill_level_{{ item.id }}" name="m_operation_skill_level[]" value="" class="" onchange="viewSelectedOperationSkill();">
                                                <option value="0">----</option>
                                                {% for itemL in data['skill.enumSkillLevels'] %}
                                                <option value="{{itemL.level}}">{{itemL.name}}</option>
                                                {% endfor %}
                                            </select>
                                         </td>
                                     </tr>
                                    {% endif %}
                                 {% endfor %}
                                </table>
                            {% endfor %}
                        {% endif %}
                    </div>
                </form>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
{#				<button type="button" class="btn btn-primary"#}
{#					onclick="">保存</button>#}
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
    <div style="width:150px;position: fixed;top:20%;right: 30%;z-index: 1100;">
        <ul class="list-group">
            <li class="list-group-item" style="">スキルカテゴリ</li>
        {% for itemC in data['skill.enumSkillCategories'] %}
            <li class="list-group-item" style="color: #428bca;cursor: pointer;height: auto;" onclick="location.href='#operation_skill_categories_header_{{ loop.index }}'">{{ itemC }}</li>
        {% endfor %}
        </ul>
    </div>
</div><!-- div.modal -->