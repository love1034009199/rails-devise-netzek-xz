class DiscountFeesController < ApplicationController
  before_action :set_discount_fee, only: [:show, :edit, :update, :destroy]

  # GET /discount_fees
  # GET /discount_fees.json
  def index
    @discount_fees = DiscountFee.all.order('updated_at DESC')
  end

  # GET /discount_fees/1
  # GET /discount_fees/1.json
  def show
  end

  # GET /discount_fees/new
  def new
    @discount_fee = DiscountFee.new
  end

  # GET /discount_fees/1/edit
  def edit
  end

  # POST /discount_fees
  # POST /discount_fees.json
  def create
    @discount_fee = DiscountFee.new(discount_fee_params)
    @discount_fee.discount_configure=create_sql_for_config(@discount_fee)

    respond_to do |format|
      if @discount_fee.save
        format.html { redirect_to @discount_fee, notice: '优惠新建成功！' }
        format.json { render :show, status: :created, location: @discount_fee }
      else
        format.html { render :new }
        format.json { render json: @discount_fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discount_fees/1
  # PATCH/PUT /discount_fees/1.json
  def update
    respond_to do |format|
      if @discount_fee.update(discount_fee_params)
        if @discount_fee.update(discount_configure: create_sql_for_config(@discount_fee))
        format.html { redirect_to @discount_fee, notice: '优惠更新成功！' }
        format.json { render :show, status: :ok, location: @discount_fee }
      else
        format.html { render :edit }
        format.json { render json: @discount_fee.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /discount_fees/1
  # DELETE /discount_fees/1.json
  def destroy
    @discount_fee.destroy
    respond_to do |format|
      format.html { redirect_to discount_fees_url, notice: 'Discount fee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discount_fee
      @discount_fee = DiscountFee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discount_fee_params
      params.require(:discount_fee).permit(:discount_name, :discount_description, :discount_configure, :discount_remark)
    end
    
  def create_sql_for_config(discount_fee)
    #定义一个数组，装载销售品ID
    @product_offering_id_array=Array.new
    @arr=Array.new
    #定义一个字符串，装载着最终生成的SQL
    @common_transform_sql_result=String.new
    #字符串连接添加数据
    @common_transform_sql_result += %Q/
declare
begin/
    #获取资费配置内容
    discount_description_str=discount_fee.discount_description
    #logger.debug "##########################################{ordinaryPromotion.ordinary_promotion_content}"
    #对资费配置内容循环拆分
    discount_description_str.each_line { |s|
      #移除字符串尾部的分离符,例如\n,\r等..
      s=s.chomp
      #判断是还是为空
      next if s.empty?
      #正则表达式匹配行尾
      next if /^#/.match(s)
      #正则表达式制表符分隔折分
      arr=s.split("\t")
      #字符串连接添加数据
      @common_transform_sql_result += %Q/
----销售品
----select a.*,rowid from   pd.pm_product_offering a where product_offering_id in(#{arr[0]});
insert into pd.PM_PRODUCT_OFFERING (PRODUCT_OFFERING_ID, OFFER_TYPE_ID, NAME, BRAND_SEGMENT_ID, IS_MAIN, LIFECYCLE_STATUS_ID, OPERATOR_ID, PROD_SPEC_ID, OFFER_CLASS, PRIORITY, BILLING_PRIORITY, IS_GLOBAL, VALID_DATE, EXPIRE_DATE, DESCRIPTION, SPEC_TYPE_FLAG)
values (#{arr[0]}, 0, '#{arr[1]}', -1, 0, 1, 0, 10180000, '111', 0, #{arr[3]}, 0, to_date('#{arr[2]}', 'yyyymmdd'), to_date('01-01-2030', 'dd-mm-yyyy'), '#{arr[1]}', 0);
----select * from pd.PM_PRODUCT_SPEC_TYPE a where a.spec_type_id=101;
----select * from pd.PM_PRODUCT_SPEC_TYPE_GROUPS a where a.prod_spec_id=10180000;
----select * from pd.PM_PRODUCT_SPEC  a where a.prod_spec_id=10180000;
----select a.*,rowid from pd.PM_PRODUCT_OFFER_LIFECYCLE a where PRODUCT_OFFERING_ID in(#{arr[0]});
insert into pd.PM_PRODUCT_OFFER_LIFECYCLE (PRODUCT_OFFERING_ID, HALF_CYCLE_FLAG, CYCLE_UNIT, CYCLE_TYPE, CYCLE_SYNC_FLAG, SUB_EFFECT_MODE, SUB_DELAY_UNIT, SUB_DELAY_CYCLE, UNSUB_EFFECT_MODE, UNSUB_DELAY_UNIT, UNSUB_DELAY_CYCLE, VALID_UNIT, VALID_TYPE, FIXED_EXPIRE_DATE, MODIFY_DATE)
values (#{arr[0]}, 0, -999, -999, 1, 0, 0, 1, 0, 0, 1, 1, 1, null, to_date('#{arr[2]}', 'yyyymmdd'));
----select a.*,rowid from pd.PM_PRODUCT_OFFER_ATTRIBUTE a where PRODUCT_OFFERING_ID  in(#{arr[0]});
insert into pd.PM_PRODUCT_OFFER_ATTRIBUTE (PRODUCT_OFFERING_ID, POLICY_ID, BILLING_TYPE, SUITABLE_NET, PROBATION_EFFECT_MOD, PROBATION_CYCLE_UNIT, PROBATION_CYCLE_TYPE, OFFSET_CYCLE_TYPE, OFFSET_CYCLE_UNIT, IS_REFUND, DISCOUNT_EXPIRE_MODE, DEPEND_FREERES_ITEM, AVAILABLE_SEG_ID)
values (#{arr[0]}, 10800000, 1, -1, 0, -999, -999, null, null, 0, 0, null, 0);
----select  a.*,rowid  from pd.PM_COMPOSITE_DEDUCT_RULE a  where PRODUCT_OFFERING_ID  in(#{arr[0]});
insert into pd.PM_COMPOSITE_DEDUCT_RULE (PRODUCT_OFFERING_ID, BILLING_TYPE, RESOURCE_FLAG, DEDUCT_FLAG, RENT_DEDUCT_RULE_ID, PRORATE_DEDUCT_RULE_ID, FAILURE_RULE_ID, REDO_AF_TOPUP, NEGATIVE_FLAG, IS_CHANGE_BILL_CYCLE, IS_PER_BILL, RETRY_MODE, RETRY_TIME, RETRY_CYCLES, INTERVAL_CYCLE_TYPE, INTERVAL_CYCLE_UNIT, CYCLE_TYPE, CYCLE_UNIT, NEED_AUTH, MAIN_PROMOTION)
values (#{arr[0]}, 1, 0, 1, -1, 1002, -1, 1, 0, 0, 0, 0, 0, 0, null, null, -999, -999, 0, -1);
----select  a.*,rowid from pd.PM_OFFERING_BRAND_REL a   where PRODUCT_OFFERING_ID  in(#{arr[0]});
insert into pd.PM_OFFERING_BRAND_REL (PRODUCT_OFFERING_ID, BRAND_ID, VALID_DATE, EXPIRE_DATE)
values (#{arr[0]}, 0, to_date('#{arr[2]}', 'yyyymmdd'), to_date('01-01-2030', 'dd-mm-yyyy'));
/
      #判断科目是否新增
      if arr[4] !="0"
        #字符串连接添加数据
        @common_transform_sql_result += %Q/     
----科目
------新增base_item
----select A.*,ROWID from  pd.PM_PRICE_EVENT A  WHERE ITEM_ID  in (#{arr[3]});
insert into pd.PM_PRICE_EVENT (ITEM_ID, NAME, SERVICE_SPEC_ID, ITEM_TYPE, SUB_TYPE, PRIORITY, DESCRIPTION)
values (#{arr[3]}, '#{arr[4]}', 0, 2, 0, 0, '#{arr[4]}');
----select * from PD.PM_ACCUMULATE_ITEM_REL A WHERE A.ITEM_ID in (#{arr[3]});
insert into PD.PM_ACCUMULATE_ITEM_REL select ACCUMULATE_ITEM,#{arr[3]}, 0, 0, null, 0 from ngcp.pm_items_references where child_item=80000600;/
      end
      
      if arr[6] !="0"
        #字符串连接添加数据
        @common_transform_sql_result += %Q/     
----科目
------新增adjust_item
----select A.*,ROWID from  pd.PM_PRICE_EVENT A  WHERE ITEM_ID  in (#{arr[5]});
insert into pd.PM_PRICE_EVENT (ITEM_ID, NAME, SERVICE_SPEC_ID, ITEM_TYPE, SUB_TYPE, PRIORITY, DESCRIPTION)
values (#{arr[5]}, '#{arr[6]}', 0, 2, 0, 0, '#{arr[6]}');
----select * from PD.PM_ACCUMULATE_ITEM_REL A WHERE A.ITEM_ID in (#{arr[5]});
insert into PD.PM_ACCUMULATE_ITEM_REL select ACCUMULATE_ITEM,#{arr[5]}, 0, 0, null, 0 from ngcp.pm_items_references where child_item=80000600;/
      end    
      
      
      
      @common_transform_sql_result += %Q/
----定价计划配置
---- select T.*,ROWID from PD.PM_PRICING_PLAN T WHERE T.PRICING_PLAN_ID IN in (#{arr[0]});
insert into PD.PM_PRICING_PLAN (PRICING_PLAN_ID, PRICING_PLAN_NAME, PRICING_PLAN_DESC, REMARKS)
values (#{arr[0]}, '#{arr[1]}', '#{arr[1]}', '帐务优惠');
----select  T.*,ROWID  from PD.PM_PRODUCT_PRICING_PLAN T WHERE T.PRODUCT_OFFERING_ID in (#{arr[0]});
insert into PD.PM_PRODUCT_PRICING_PLAN (PRODUCT_OFFERING_ID, POLICY_ID, PRICING_PLAN_ID, PRIORITY, MAIN_PROMOTION, DISP_FLAG)
values (#{arr[0]}, 11800000, #{arr[0]}, 1, -1, 0);
----select  T.*,ROWID  from PD.PM_COMPONENT_PRODOFFER_PRICE  T WHERE T.PRICE_ID  in (#{arr[0]});
insert into PD.PM_COMPONENT_PRODOFFER_PRICE (PRICE_ID, NAME, PRICE_TYPE, TAX_INCLUDED, DESCRIPTION)
values (#{arr[0]}, '#{arr[1]}', 8, 2, '#{arr[1]}');
---- select T.*,ROWID  from PD.PM_COMPOSITE_OFFER_PRICE T WHERE T.PRICING_PLAN_ID  in (#{arr[0]});
insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID, PRICE_ID, BILLING_TYPE, OFFER_STS, VALID_DATE, EXPIRE_DATE)
values (#{arr[0]}, #{arr[0]}, 1, 0, to_date('#{arr[2]}', 'yyyymmdd'), to_date('01-01-2030', 'dd-mm-yyyy'));
----select T.*,ROWID  from PD.PM_ADJUST_RATES T WHERE T.ADJUSTRATE_ID in (#{arr[0]});
insert into PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
values (#{arr[0]}, 0, '#{arr[1]}');
----select  T.*,ROWID   from  PD.PM_BILLING_DISCOUNT_DTL T WHERE T.PRICE_ID in (#{arr[0]});
--当有多条记录时，通过CALC_SERIAL控制先后顺序
insert into PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID, VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
values (#{arr[0]}, 1, #{arr[0]}, to_date('#{arr[2]}', 'yyyymmdd'), to_date('01-01-2030', 'dd-mm-yyyy'), '1011000000', 10403, '#{arr[1]}');
----select  T.*,ROWID  from PD.PM_ADJUST_SEGMENT T WHERE T.ADJUSTRATE_ID in (#{arr[0]});
insert into PD.PM_ADJUST_SEGMENT (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE, EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM, ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID, PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE, FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION, FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
values (#{arr[0]}, #{arr[7]}, 2, 0, -1, #{arr[3]}, 1, #{arr[5]}, 1, 0, 1, 24, 0, -1, #{arr[8]}, 1, 0, 3, 0, 3, 0, 1, 89060001, -1, 0, 0, null, null, '优惠西藏手机报', 0, -1, 0);

/

      #把产品ID存储装载
      @product_offering_id_array << arr[0]
    }
    @common_transform_sql_result +=  %Q/
end;


--优惠
select a.product_offering_id,
       a.name,
       a.billing_priority,            ---表示帐务扣费优先级，冲销里面要用到的
       b.policy_id,                    --该产品挂的定价计划的生效条件
       b.pricing_plan_id,          --该销售品下挂的定价计划
       d.price_id,                     --定价计划下的价格ID
       d.billing_type,                ---该帐务优惠产品适用的计费类型（0-预付费，1-后付费，-1适用所有的计费类型）
       e.price_type,                 ---为8表示帐务优惠产品
       nvl(e.tax_included, 0) as "是否含税标识", ---该定价ID是否含税标识（0：含税无关，1：不含税，2：含税；目前固费、一次性费用、基本资费需要关注含税标示，其他PRICE填0）
       f.calc_serial,                 ---计算序号
       f.use_type,                  ---日月帐
       g.adjustrate_id,            ---校正费率ID
       g.calc_type,                 ---优惠的计算方式（0：参考科目落在某一段里面，1：参考科目落在多段里面，2：适用余计费资费）
       h.expr_id as "优惠生效条件", ---优惠的生效条件
       i.policy_expr,
       decode(h.ref_type,
              1,
              '参考原始费用',
              2,
              '参考优惠后的费用',
              3,
              '参考优惠后且包含预存的费用',
              4,
              '计费标准批价的费用',
              5,
              '增量优惠费用') as ref_type,
       h.valid_cycle, ---生效账期（0本账期生效，1下账期生效，以此类推）
       h.expire_cycle, ---生效账期个数（0表示没有限制，1表示只有一个账期，以此类推）
       h.base_item, ---参考科目，可以是实科目，也可以是虚科目
       h.adjust_item, ---校正科目，可以是实科目，也可以是优惠科目
       h.fill_item, ---分摊科目
       decode(h.adjust_type,
              00,
              '保留',
              01,
              '比例',
              02,
              '固定',
              03,
              '限额',
              04,
              '赠送免费资源',
              05,
              '赠送产品',
              06,
              '减免',
              07,
              '保底',
              08,
              '包打',
              09,
              '送当前周期后的金额,送固定金额',
              10,
              '送当前周期后的金额,按比例赠送优惠后') as adjust_type,
       h.priority, ---优惠的优先级
       h.start_val, ---校正段开始值
       h.end_val, ---校正段结束值
       h.numerator, ---校正线段分子
       h.denominator, ---校正线段分母
       h.maximum, ---优惠的最大值限制（-1表示无限制）
       h.reward_id,   ---赠送标识，取自pm_reward_def这张表
       h.precision_round, ---精度要求（1向上取整，2向下取整，3四舍五入）
       h.disc_type, ---优惠的体现类型（00无要求，01表示产生优惠科目方式，02表示减免原始费用方式）
       h.para_use_rule, ---个性化参数使用规则（0不使用，1使用）
       h.formula_id, ---优惠的计算公式
       j.policy_expr,
       j.name, ---优惠的名字
       h.donate_use_rule, ---赠送使用的规则ID
       decode(h.prom_type, ---表示优惠类型
              1,
              '打折（比例）',
              2,
              '指定（固定）',
              3,
              '封顶',
              4,
              '减免',
              5,
              '保底',
              6,
              '包打',
              7,
              '赠送优惠') as "优惠类型",
       h.ref_role, ---优惠参考角色
       h.result_role, ---优惠分摊角色
       k.measure_id, ---优惠的货币属性
       k.measure_type_id, ---优惠的货币类型，如RMB、dollar，Baht
       k.measure_level
  from pd.pm_product_offering          a,
       pd.pm_product_pricing_plan      b,
       pd.pm_pricing_plan              c,
       pd.pm_composite_offer_price     d,
       pd.pm_component_prodoffer_price e,
       pd.pm_billing_discount_dtl      f,
       pd.pm_adjust_rates              g,
       pd.pm_adjust_segment            h,
       sd.sys_policy                   i, ---和帐务优惠生效条件对应
       sd.sys_policy                   j, ---和帐务优惠计算表达式对应
       sd.sys_measure                  k
 where a.product_offering_id = b.product_offering_id
   and b.pricing_plan_id = c.pricing_plan_id
   and c.pricing_plan_id = d.pricing_plan_id
   and d.price_id = e.price_id
   and e.price_type = 8 ---当定价类型为8时表示帐务优惠产品
   and e.price_id = f.price_id
   and f.adjustrate_id = g.adjustrate_id
   and g.adjustrate_id = h.adjustrate_id
   and h.expr_id = i.policy_id ---帐务优惠的生效条件必须满足
   and h.formula_id = j.policy_id ---帐务优惠的计算公式
   and k.measure_id = f.measure_id ---度量单位必须在sys_policy表中存在
   and a.product_offering_id  in (#{@product_offering_id_array.join(",").to_s});
/
   @common_transform_sql_result
  end
  
end
