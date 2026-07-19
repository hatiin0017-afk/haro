// Supabase 설정
// 프로젝트 생성 후 아래 두 값만 채우면 됨 (Settings → API)
const SUPABASE_URL  = 'https://vmoyirfjnwzbriknqivq.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtb3lpcmZqbnd6YnJpa25xaXZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NDYyNjEsImV4cCI6MjEwMDAyMjI2MX0.DkyXeLewEkYjIHDhx5KzXT0wj6bzBMKzj_Gf9qqbUKQ';

let _sb = null;
function initSupabase(){
  if(_sb) return _sb;
  if(!SUPABASE_URL || !SUPABASE_ANON){
    console.warn('[supabase] URL/anon 미설정');
    return null;
  }
  _sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON);
  return _sb;
}
