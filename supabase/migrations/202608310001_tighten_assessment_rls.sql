drop policy if exists "users create own assessments" on public.assessments;
create policy "users create own assessments"
  on public.assessments for insert
  with check (auth.uid() = user_id);

drop policy if exists "users create own responses" on public.assessment_responses;
create policy "users create own responses"
  on public.assessment_responses for insert
  with check (
    exists (
      select 1
      from public.assessments a
      where a.id = assessment_id
        and a.user_id = auth.uid()
    )
  );

drop policy if exists "users create own scores" on public.gift_scores;
create policy "users create own scores"
  on public.gift_scores for insert
  with check (
    exists (
      select 1
      from public.assessments a
      where a.id = assessment_id
        and a.user_id = auth.uid()
    )
  );
