# frozen_string_literal: true

class AllowNullAiLevelForUnassessedPortfolioSkills < ActiveRecord::Migration[7.0]
  def up
    # 1. Remove strict NOT NULL and original check constraint
    remove_check_constraint :portfolio_skills, name: 'chk_portfolio_skills_ai_level'
    change_column_null :portfolio_skills, :ai_level, true

    # 2. Add updated check constraint permitting NULL for unassessed skills
    add_check_constraint :portfolio_skills,
                         'ai_level IS NULL OR (ai_level >= 1 AND ai_level <= 5)',
                         name: 'chk_portfolio_skills_ai_level'
  end

  def down
    # 1. Backfill any NULL values to default 1 to avoid migration failure on rollback
    execute <<~SQL
      UPDATE portfolio_skills SET ai_level = 1 WHERE ai_level IS NULL;
    SQL

    # 2. Revert constraint and column nullability
    remove_check_constraint :portfolio_skills, name: 'chk_portfolio_skills_ai_level'
    change_column_null :portfolio_skills, :ai_level, false
    add_check_constraint :portfolio_skills,
                         'ai_level >= 1 AND ai_level <= 5',
                         name: 'chk_portfolio_skills_ai_level'
  end
end
