class PrimaryFeesController < ApplicationController
  before_action :set_primary_fee, only: [:show, :edit, :update, :destroy]

  # GET /primary_fees
  # GET /primary_fees.json
  def index
    # @primary_fees = PrimaryFee.all
    @primary_fees = PrimaryFee.all.order('updated_at DESC')
  end

  # GET /primary_fees/1
  # GET /primary_fees/1.json
  def show
  end

  # GET /primary_fees/new
  def new
    @primary_fee = PrimaryFee.new
  end

  # GET /primary_fees/1/edit
  def edit
  end

  # POST /primary_fees
  # POST /primary_fees.json
  def create

    
    @primary_fee = PrimaryFee.new(primary_fee_params)
    @primary_fee.primary_configure=create_sql_for_config(@primary_fee)

    respond_to do |format|
      if @primary_fee.save
        format.html { redirect_to @primary_fee, notice: '固定费新建成功！' }
        format.json { render :show, status: :created, location: @primary_fee }
      else
        format.html { render :new }
        format.json { render json: @primary_fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /primary_fees/1
  # PATCH/PUT /primary_fees/1.json
  def update
    respond_to do |format|
      if @primary_fee.update(primary_fee_params)
        if @primary_fee.update(primary_configure: create_sql_for_config(@primary_fee))
        format.html { redirect_to @primary_fee, notice: '固定费更新成功！' }
        format.json { render :show, status: :ok, location: @primary_fee }
      else
        format.html { render :edit }
        format.json { render json: @primary_fee.errors, status: :unprocessable_entity }
      end
    end
  end
  end

  # DELETE /primary_fees/1
  # DELETE /primary_fees/1.json
  def destroy
    @primary_fee.destroy
    respond_to do |format|
      format.html { redirect_to primary_fees_url, notice: 'Primary fee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_primary_fee
      @primary_fee = PrimaryFee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def primary_fee_params
      params.require(:primary_fee).permit(:primary_name, :primary_description, :primary_configure, :primary_remark)
    end
    
    
     def create_sql_for_config(primary_fee)

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
    ordinary_promotion_content_str=primary_fee.primary_description
    #logger.debug "##########################################{ordinaryPromotion.ordinary_promotion_content}"
    #对资费配置内容循环拆分
    ordinary_promotion_content_str.each_line { |s|
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
values (#{arr[0]}, 0, '#{arr[1]}', -1, 0, 1, 0, 10180000, '111', 0, 0, 0, to_date('#{arr[2]}', 'yyyymmdd'), to_date('01-01-2030', 'dd-mm-yyyy'), '#{arr[1]}', 0);
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
----select A.*,ROWID from  pd.PM_PRICE_EVENT A  WHERE ITEM_ID  in (#{arr[3]});
insert into pd.PM_PRICE_EVENT (ITEM_ID, NAME, SERVICE_SPEC_ID, ITEM_TYPE, SUB_TYPE, PRIORITY, DESCRIPTION)
values (#{arr[3]}, '#{arr[4]}', 0, 2, 0, 0, '#{arr[4]}');
----select * from PD.PM_ACCUMULATE_ITEM_REL A WHERE A.ITEM_ID in (#{arr[3]});
insert into PD.PM_ACCUMULATE_ITEM_REL select ACCUMULATE_ITEM,#{arr[3]}, 0, 0, null, 0 from ngcp.pm_items_references where child_item=80000600;/
      end
      
      @common_transform_sql_result += %Q/
----定价计划配置
----select A.*,ROWID from PD.PM_PRICING_PLAN  A WHERE A.PRICING_PLAN_ID in (#{arr[0]});
insert into PD.PM_PRICING_PLAN (PRICING_PLAN_ID, PRICING_PLAN_NAME, PRICING_PLAN_DESC, REMARKS)
values (#{arr[0]}, '#{arr[1]}', '#{arr[1]}', '#{arr[1]}');
----select A.*,ROWID from PD.PM_PRODUCT_PRICING_PLAN A  where PRODUCT_OFFERING_ID in (#{arr[0]});
insert into PD.PM_PRODUCT_PRICING_PLAN (PRODUCT_OFFERING_ID, POLICY_ID, PRICING_PLAN_ID, PRIORITY, MAIN_PROMOTION, DISP_FLAG)
values (#{arr[0]}, 11800000, #{arr[0]}, 1, -1, 0);
/
 #字符串连接添加数据
      @common_transform_sql_result += %Q/
--定价
----select * from PD.PM_COMPONENT_PRODOFFER_PRICE T WHERE T.PRICE_ID IN (#{arr[6]},#{arr[7]});
insert into PD.PM_COMPONENT_PRODOFFER_PRICE (PRICE_ID, NAME, PRICE_TYPE, TAX_INCLUDED, DESCRIPTION)
values (#{arr[6]}, '#{arr[1]}', 7, 2, '#{arr[1]}');
insert into PD.PM_COMPONENT_PRODOFFER_PRICE (PRICE_ID, NAME, PRICE_TYPE, TAX_INCLUDED, DESCRIPTION)
values (#{arr[7]}, '#{arr[1]}', 7, 2, '#{arr[1]}');
----select * from PD.PM_RECURRING_FEE_DTL T WHERE T.PRICE_ID IN (#{arr[6]},#{arr[7]});
insert into PD.PM_RECURRING_FEE_DTL (PRICE_ID, ITEM_CODE, RATE_ID, ACCOUNT_TYPE, VALID_CYCLE, VALID_COUNT, PRE_PAY_TYPE, CAL_INDI, EXPR_ID, PRIORITY, USE_MARKER_ID, SEG_INDI, SEG_REP, DESCRIPTION, PARAM_MODE)
values (#{arr[6]}, #{arr[3]}, #{arr[6]}, 3, 0, -1, 0, 20, #{arr[5]}, 2, 88300003, 0, 0, '#{arr[1]}', 0);
insert into PD.PM_RECURRING_FEE_DTL (PRICE_ID, ITEM_CODE, RATE_ID, ACCOUNT_TYPE, VALID_CYCLE, VALID_COUNT, PRE_PAY_TYPE, CAL_INDI, EXPR_ID, PRIORITY, USE_MARKER_ID, SEG_INDI, SEG_REP, DESCRIPTION, PARAM_MODE)
values (#{arr[7]}, #{arr[3]}, #{arr[7]}, 3, 0, -1, 0, 20, #{arr[5]}, 3, 88300001, 0, 0, '#{arr[1]}', 0);
----select * from pd.PM_RATES  t where t.rate_id in  (#{arr[6]},#{arr[7]})
insert into pd.PM_RATES (RATE_ID, RATE_NAME, SERVICE_ID, MINIMUM, MAXIMUM, RATE_PRECISION, PRECISION_ROUND, CURVE_ID, MEASURE_ID, DESCRIPTION)
values (#{arr[6]}, '#{arr[1]}', 0, 0, -1, 10, 3, '#{arr[6]}', 10402, '#{arr[1]}');
insert into pd.PM_RATES (RATE_ID, RATE_NAME, SERVICE_ID, MINIMUM, MAXIMUM, RATE_PRECISION, PRECISION_ROUND, CURVE_ID, MEASURE_ID, DESCRIPTION)
values (#{arr[7]}, '#{arr[1]}', 0, 0, -1, 10, 3, '#{arr[7]}', 10402, '#{arr[1]}');
----select * from pd.PM_CURVE t where t.curve_id (#{arr[6]},#{arr[7]});
insert into pd.PM_CURVE (CURVE_ID, DESCRIPTION)
values (#{arr[6]}, '#{arr[1]}');
insert into pd.PM_CURVE (CURVE_ID, DESCRIPTION)
values (#{arr[7]}, '#{arr[1]}');
----select * from pd.PM_CURVE_SEGMENTS t where t.curve_id (#{arr[6]},#{arr[7]});
insert into pd.PM_CURVE_SEGMENTS (CURVE_ID, SEGMENT_ID, START_VAL, END_VAL, BASE_VAL, RATE_VAL, TAIL_UNIT, TAIL_ROUND, TAIL_RATE, FORMULA_ID, SHARE_NUM, DESCRIPTION)
values (#{arr[6]}, 1, 0, -1, #{arr[8]}, 0, 0, 0, 0, 89300001, 0, '#{arr[1]}');
insert into pd.PM_CURVE_SEGMENTS (CURVE_ID, SEGMENT_ID, START_VAL, END_VAL, BASE_VAL, RATE_VAL, TAIL_UNIT, TAIL_ROUND, TAIL_RATE, FORMULA_ID, SHARE_NUM, DESCRIPTION)
values (#{arr[7]}, 1, 0, -1, #{arr[8]}, 0, 0, 0, 0, 89300001, 0, '#{arr[1]}');
/

      #把产品ID存储装载
      @product_offering_id_array << arr[0]
    }
    @common_transform_sql_result +=  %Q/
end;

select a.product_offering_id,
       a.name,
       a.valid_date,
       a.expire_date,
       b.pricing_plan_id,
              c.price_id,
       d.expr_id,
       h.name   产品生效条件,
       h.policy_expr,
       d.priority,
       d.use_marker_id,
       i.policy_expr,
       i.name,
       d.rate_id,
       e.curve_id,
       g.formula_id,      
       j.description,
       j.policy_expr,
       d.item_code,
       l.name,
       g.base_val,
       g.rate_val,
       decode(d.account_type, 1, '月帐', 2, '日帐', 3, '日月帐', '未定义') as account_type
  from pd.pm_product_offering      a,
       pd.pm_product_pricing_plan  b,
       pd.pm_composite_offer_price c,
       pd.pm_recurring_fee_dtl     d,
       pd.pm_rates                 e,
       pd.pm_curve                 f,
       pd.pm_curve_segments        g,
       sd.sys_policy               h,
       sd.sys_policy               i,
       sd.sys_policy               j,
       pd.pm_price_event           l
 where a.product_offering_id = b.product_offering_id
   and b.pricing_plan_id = c.pricing_plan_id
   and c.price_id = d.price_id
   and d.rate_id = e.rate_id
   and e.curve_id = f.curve_id
   and f.curve_id = g.curve_id
   and d.item_code=l.item_id
   and d.expr_id=h.policy_id
   and d.use_marker_id=i.policy_id
   and g.formula_id = j.policy_id
   and a.product_offering_id in (#{@product_offering_id_array.join(",").to_s}
);
/
   @common_transform_sql_result
  end
    
end
