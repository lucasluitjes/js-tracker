defmodule JsTrackerWeb.TargetControllerTest do
  use JsTrackerWeb.ConnCase

  alias JsTracker.Tracker

  @create_attrs %{url: "some url"}
  @update_attrs %{url: "some updated url"}
  @invalid_attrs %{url: nil}

  def fixture(:target) do
    {:ok, target} = Tracker.create_target(@create_attrs)
    target
  end

  describe "index" do
    test "lists all targets", %{conn: conn} do
      conn = get conn, target_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Targets"
    end
  end

  describe "new target" do
    test "renders form", %{conn: conn} do
      conn = get conn, target_path(conn, :new)
      assert html_response(conn, 200) =~ "New Target"
    end
  end

  describe "create target" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, target_path(conn, :create), target: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == target_path(conn, :show, id)

      conn = get conn, target_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Target"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, target_path(conn, :create), target: @invalid_attrs
      assert html_response(conn, 200) =~ "New Target"
    end
  end

  describe "edit target" do
    setup [:create_target]

    test "renders form for editing chosen target", %{conn: conn, target: target} do
      conn = get conn, target_path(conn, :edit, target)
      assert html_response(conn, 200) =~ "Edit Target"
    end
  end

  describe "update target" do
    setup [:create_target]

    test "redirects when data is valid", %{conn: conn, target: target} do
      conn = put conn, target_path(conn, :update, target), target: @update_attrs
      assert redirected_to(conn) == target_path(conn, :show, target)

      conn = get conn, target_path(conn, :show, target)
      assert html_response(conn, 200) =~ "some updated url"
    end

    test "renders errors when data is invalid", %{conn: conn, target: target} do
      conn = put conn, target_path(conn, :update, target), target: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Target"
    end
  end

  describe "delete target" do
    setup [:create_target]

    test "deletes chosen target", %{conn: conn, target: target} do
      conn = delete conn, target_path(conn, :delete, target)
      assert redirected_to(conn) == target_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, target_path(conn, :show, target)
      end
    end
  end

  defp create_target(_) do
    target = fixture(:target)
    {:ok, target: target}
  end
end
